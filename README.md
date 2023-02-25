Mongoid::Scroll
===============

[![Gem Version](https://badge.fury.io/rb/mongoid-scroll.svg)](https://badge.fury.io/rb/mongoid-scroll)
[![Build Status](https://github.com/mongoid/mongoid-scroll/actions/workflows/ci.yml/badge.svg)](https://github.com/mongoid/mongoid-scroll/actions/workflows/ci.yml)
[![Dependency Status](https://gemnasium.com/mongoid/mongoid-scroll.svg)](https://gemnasium.com/mongoid/mongoid-scroll)
[![Code Climate](https://codeclimate.com/github/mongoid/mongoid-scroll.svg)](https://codeclimate.com/github/mongoid/mongoid-scroll)

Mongoid extension that enables infinite scrolling for `Mongoid::Criteria`, `Moped::Query` and `Mongo::Collection::View`.

Compatibility
-------------

This gem supports Mongoid 3, 4, 5, 6, 7, Moped and Mongo-Ruby-Driver.

Demo
----

Check out [shows on artsy.net](http://artsy.net/shows). Keep scrolling down.

There're also two code samples for Mongoid and Moped in [examples](examples). Run `bundle exec ruby examples/mongoid_scroll_feed.rb`.

The Problem
-----------

Traditional pagination does not work when data changes between paginated requests, which makes it unsuitable for infinite scroll behaviors.

* If a record is inserted before the current page limit, items will shift right, and the next page will include a duplicate.
* If a record is removed before the current page limit, items will shift left, and the next page will be missing a record.

The solution implemented by the `scroll` extension paginates data using a cursor, giving you the ability to restart pagination where you left it off. This is a non-trivial problem when combined with sorting over non-unique record fields, such as timestamps.

Installation
------------

Add the gem to your Gemfile and run `bundle install`.

```ruby
gem 'mongoid-scroll'
```

Usage
-----

### Mongoid

A sample model.

```ruby
module Feed
  class Item
    include Mongoid::Document
    field :title, type: String
    field :position, type: Integer
    index({ position: 1, _id: 1 })
  end
end
```

Scroll by `:position` and save a cursor to the last item.

```ruby
saved_cursor = nil
Feed::Item.desc(:position).limit(5).scroll do |record, next_cursor|
  # each record, one-by-one
  saved_cursor = next_cursor
end
```

Resume iterating using the previously saved cursor.

```ruby
Feed::Item.desc(:position).limit(5).scroll(saved_cursor) do |record, next_cursor|
  # each record, one-by-one
  saved_cursor = next_cursor
end
```

The iteration finishes when no more records are available. You can also finish iterating over the remaining records by omitting the query limit.

```ruby
Feed::Item.desc(:position).scroll(saved_cursor) do |record, next_cursor|
  # each record, one-by-one
end
```

### Moped (Mongoid 3 and 4)

Scroll a `Moped::Query` and save a cursor to the last item. You must also supply a `field_type` of the sort criteria.

```ruby
saved_cursor = nil
session[:feed_items].find.sort(position: -1).limit(5).scroll(nil, { field_type: DateTime }) do |record, next_cursor|
  # each record, one-by-one
  saved_cursor = next_cursor
end
```

Resume iterating using the previously saved cursor.

```ruby
session[:feed_items].find.sort(position: -1).limit(5).scroll(saved_cursor, { field_type: DateTime }) do |record, next_cursor|
  # each record, one-by-one
  saved_cursor = next_cursor
end
```

### Mongo-Ruby-Driver (Mongoid 5)

Scroll a `Mongo::Collection::View` and save a cursor to the last item. You must also supply a `field_type` of the sort criteria.

```ruby
saved_cursor = nil
client[:feed_items].find.sort(position: -1).limit(5).scroll(nil, { field_type: DateTime }) do |record, next_cursor|
  # each record, one-by-one
  saved_cursor = next_cursor
end
```

Resume iterating using the previously saved cursor.

```ruby
session[:feed_items].find.sort(position: -1).limit(5).scroll(saved_cursor, { field_type: DateTime }) do |record, next_cursor|
  # each record, one-by-one
  saved_cursor = next_cursor
end
```

Indexes and Performance
-----------------------

A query without a cursor is identical to a query without a scroll.

``` ruby
# db.feed_items.find().sort({ position: 1 }).limit(7)
Feed::Item.desc(:position).limit(7).scroll
```

Subsequent queries use an `$or` to avoid skipping items with the same value as the one at the current cursor position.

``` ruby
# db.feed_items.find({ "$or" : [
#   { "position" : { "$gt" : 13 }},
#   { "position" : 13, "_id": { "$gt" : ObjectId("511d7c7c3b5552c92400000e") }}
# ]}).sort({ position: 1 }).limit(7)
Feed:Item.desc(:position).limit(7).scroll(cursor)
```

This means you need to hit an index on `position` and `_id`.

``` ruby
# db.feed_items.ensureIndex({ position: 1, _id: 1 })

module Feed
  class Item
    ...
    index({ position: 1, _id: 1 })
  end
end
```

Cursors
-------

You can use `Mongoid::Scroll::Cursor.from_record` to generate a cursor. A cursor points at the last record of the previous iteration and unlike MongoDB cursors will not expire.

```ruby
record = Feed::Item.desc(:position).limit(3).last
cursor = Mongoid::Scroll::Cursor.from_record(record, { field: Feed::Item.fields["position"] })
# cursor or cursor.to_s can be returned to a client and passed into .scroll(cursor)
```

You can also a `field_name` and `field_type` instead of a Mongoid field.

```ruby
cursor = Mongoid::Scroll::Cursor.from_record(record, { field_type: DateTime, field_name: "position" })
```

When the `include_current` option is set to `true`, the cursor will include the record it points to:

```ruby
record = Feed::Item.desc(:position).limit(3).last
cursor = Mongoid::Scroll::Cursor.from_record(record, { field: Feed::Item.fields["position"], include_current: true })
Feed::Item.asc(:position).limit(1).scroll(cursor).first # record
```

If the `field_name`, `field_type` or `direction` options you specify when creating the cursor are different from the original criteria, a `Mongoid::Scroll::Errors::MismatchedSortFieldsError` will be raised.

```ruby
cursor = Mongoid::Scroll::Cursor.from_record(record, { field_type: DateTime, field_name: "position" })
Feed::Item.desc(:created_at).scroll(cursor) # Raises a Mongoid::Scroll::Errors::MismatchedSortFieldsError
```

Contributing
------------

Fork the project. Make your feature addition or bug fix with tests. Send a pull request. Bonus points for topic branches.

Copyright and License
---------------------

MIT License, see [LICENSE](http://github.com/mongoid/mongoid-scroll/raw/master/LICENSE.md) for details.

(c) 2013-2015 [Daniel Doubrovkine](http://github.com/dblock), based on code by [Frank Macreery](http://github.com/macreery), [Artsy Inc.](http://artsy.net)
