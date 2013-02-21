0.2.1 (3/21/2013)
=================

* Fix: scroll over a collection that has duplicate values while data is being modified in a way that causes a change in the natural sort order - [@dblock](https://github.com/dblock).

0.2.0 (3/14/2013)
=================

* Extended `Moped::Query` with `scroll` - [@dblock](https://github.com/dblock).
* `Mongoid::Scroll::Cursor.from_record` can now be called with either a Mongoid field or `field_type` and `field_name` in the `options` hash - [@dblock](https://github.com/dblock).

0.1.0 (2/14/2013)
=================

* Initial public release, extends `Mongoid::Criteria` with `scroll` - [@dblock](https://github.com/dblock).

