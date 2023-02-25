# Upgrading

## Upgrading to >= 1.0.0

### Mismatched Sort Fields

`Mongoid::Criteria::Scrollable#scroll`, `Moped::Scrollable` and `Mongo::Scrollable` now raise a `Mongoid::Scroll::Errors::MismatchedSortFieldsError` when there are discrepancies between the cursor sort options and the original sort options.
Make sure to avoid this case or to handle the new exception.

```ruby
cursor.field_name = "position" # Avoid this, it'll raise because on the following line the sort is by created_at
Feed::Item.desc(:created_at).scroll(cursor)
```

```ruby
begin
  Feed::Item.desc(:created_at).scroll(cursor)
rescue Mongoid::Scroll::Errors::MismatchedSortFieldsError
  # If cursor can be modified externally, handle the exception
end
```
