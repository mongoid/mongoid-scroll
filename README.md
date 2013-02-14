Mongoid::Scroll [![Build Status](https://travis-ci.org/dblock/mongoid-scroll.png?branch=master)](https://travis-ci.org/dblock/mongoid-scroll)
===============

Mongoid extension that enables infinite scrolling for `Mongoid::Criteria` and `Moped::Query`.

Demo
----

Check out [artsy.net](http://artsy.net) homepage. Scroll down.

The Problem
-----------

Traditional pagination does not work when data changes between paginated requests, which makes it unsuitable for infinite scroll behaviors.

* If a record is inserted before the current page limit, the collection will shift to the right, and the returned result will include a duplicate from a previous page.
* If a record is removed before the current page limit, the collection will shift to the left, and the returned result will be missing a record.

The solution implemented by the `scroll` extension paginates data using a cursor, giving you the ability to restart pagination where you left it off. This is a non-trivial problem when combined with sorting over non-unique record fields, such as timestamps.

Installation
------------

Add the gem to Gemfile and run `bundle install`.

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
    field :content, type: String
    field :created_at, type: DateTime
  end
end
```

Scroll and save a cursor to the last item.

```ruby
saved_cursor = nil
Feed::Item.desc(:created_at).limit(5).scroll do |record, next_cursor|
  # each record, one-by-one
  saved_cursor = next_cursor
end
```

Resume iterating using the previously saved cursor.

```ruby
Feed::Item.desc(:created_at).limit(5).scroll(saved_cursor) do |record, next_cursor|
  # each record, one-by-one
  saved_cursor = next_cursor
end
```

The iteration finishes when no more records are available. You can also finish iterating over the remaining records by omitting the query limit.

```ruby
Feed::Item.desc(:created_at).scroll(saved_cursor) do |record, next_cursor|
  # each record, one-by-one
end
```

### Moped

Scroll and save a cursor to the last item. Note that you need to supply a `field_type`.

```ruby
saved_cursor = nil
session[:splines].find.sort(created_at: -1).limit(5).scroll(nil, { field_type: DateTime }) do |record, next_cursor|
  # each record, one-by-one
  saved_cursor = next_cursor
end
```

Resume iterating using the previously saved cursor.

```ruby
session[:splines].find.sort(created_at: -1).limit(5).scroll(saved_cursor, { field_type: DateTime }) do |record, next_cursor|
  # each record, one-by-one
  saved_cursor = next_cursor
end
```

Cursors
-------

You can use `Mongoid::Scroll::Cursor.from_record` to generate a cursor. This can be useful when you just want to return a collection of results and the cursor pointing to after the last item.

```ruby
record = Feed::Item.desc(:created_at).limit(3).last
cursor = Mongoid::Scroll::Cursor.from_record(record, { field: Feed::Item.fields["created_at"] })
# cursor or cursor.to_s can be returned to a client and passed into .scroll(cursor)
```

You can also a `field_name` and `field_type` instead of a Mongoid field.

```ruby
cursor = Mongoid::Scroll::Cursor.from_record(record, { field_type: DateTime, field_name: "created_at" })
```


Note that unlike MongoDB cursors, `Mongoid::Scroll::Cursor` values don't expire.

Contributing
------------

Fork the project. Make your feature addition or bug fix with tests. Send a pull request. Bonus points for topic branches.

Copyright and License
---------------------

MIT License, see [LICENSE](http://github.com/dblock/mongoid-scroll/raw/master/LICENSE.md) for details.

(c) 2013 [Daniel Doubrovkine](http://github.com/dblock), based on code by [Frank Macreery](http://github.com/macreery), [Artsy Inc.](http://artsy.net)
