# Upgrading

## Upgrading to >= 2.0.0

The second argument yielded in the block in `Mongoid::Criteria::Scrollable#scroll` and `Mongo::Scrollable#scroll` has changed from a cursor to an instance of `Mongoid::Criteria::Scrollable` which provides `next_cursor` and `previous_cursor`. The `next_cursor` method returns the same cursor as in versions prior to 2.0.0.

For example, this code:

```ruby
Feed::Item.asc(field_name).limit(2).scroll(cursor) do |_, next_cursor|
  cursor = next_cursor
end
```

Should be updated to:

```
Feed::Item.asc(field_name).limit(2).scroll(cursor) do |_, iterator|
  cursor = iterator.next_cursor
end
```

## Upgrading to >= 1.0.0

### Mismatched Sort Fields

Both `Mongoid::Criteria::Scrollable#scroll` and `Mongo::Scrollable` now raise a `Mongoid::Scroll::Errors::MismatchedSortFieldsError` when there are discrepancies between the cursor sort options and the original sort options.

For example, the following code will now raise a `MismatchedSortFieldsError` because we set a different field name (`position`) from the `created_at` field used to sort in `scroll`.

```ruby
cursor.field_name = "position"
Feed::Item.desc(:created_at).scroll(cursor)
```
