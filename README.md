Mongoid::Scroll [![Build Status](https://travis-ci.org/dblock/mongoid-scroll.png?branch=master)](https://travis-ci.org/dblock/mongoid-scroll)
===============

Mongoid extension that enable infinite scroll.

The Problem
-----------

Traditional pagination does not work when data changes between paginated requests, which makes it unsuitable for infinite scroll behaviors.

* If a record is inserted before the current page limit, the collection will shift to the right, and the returned result will include a duplicate from a previous page.
* If a record is removed before the current page limit, the collection will shift to the left, and the returned result will be missing a record.

The solution implemented by the `scroll` extension paginates data using a cursor, giving you the ability to restart pagination where you left it off. This is a non-trivial problem when combined with sorting over non-unique record fields, such as timestamps.

Usage
=====

Add `mongoid-scroll` to Gemfile.

```ruby
gem 'mongoid-scroll'
```

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

Contributing
------------

Fork the project. Make your feature addition or bug fix with tests. Send a pull request. Bonus points for topic branches.

Copyright and License
---------------------

MIT License, see [LICENSE](http://github.com/dblock/mongoid-scroll/raw/master/LICENSE.md) for details.

(c) 2013 [Daniel Doubrovkine](http://github.com/dblock), based on code by [Frank Macreery](http://github.com/macreery), [Artsy Inc.](http://artsy.net)
