0.3.3 (Next)
------------

* Your contribution here.

0.3.2 (8/8/2015)
----------------

* [#7](https://github.com/dblock/mongoid-scroll/pull/7): Fix: pre-merge cursor criteria fields - [@sweir27](https://github.com/sweir27).

0.3.1 (7/27/2015)
-----------------

* Compatibility with Mongoid 5.x beta - [@dblock](https://github.com/dblock).
* [#4](https://github.com/dblock/mongoid-scroll/pull/4): Fix: support chaining `$or` criteria - [@sweir27](https://github.com/sweir27).
* [#5](https://github.com/dblock/mongoid-scroll/pull/5): Fix: embeddable objects now returned in pagination - [@sweir27](https://github.com/sweir27).

0.3.0 (1/7/2014)
----------------

* Compatibility with Mongoid 4.x - [@dblock](https://github.com/dblock).
* Implemeneted Rubocop, Ruby linter - [@dblock](https://github.com/dblock).

0.2.1 (3/21/2013)
-----------------

* Fix: scroll over a collection that has duplicate values while data is being modified in a way that causes a change in the natural sort order - [@dblock](https://github.com/dblock).

0.2.0 (3/14/2013)
-----------------

* Extended `Moped::Query` with `scroll` - [@dblock](https://github.com/dblock).
* `Mongoid::Scroll::Cursor.from_record` can now be called with either a Mongoid field or `field_type` and `field_name` in the `options` hash - [@dblock](https://github.com/dblock).

0.1.0 (2/14/2013)
-----------------

* Initial public release, extends `Mongoid::Criteria` with `scroll` - [@dblock](https://github.com/dblock).

