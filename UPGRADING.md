# Upgrading

## Upgrading to >= 1.0.0

### Mismatched Sort Fields

Both `Mongoid::Criteria::Scrollable#scroll` and `Mongo::Scrollable` now raise a `Mongoid::Scroll::Errors::MismatchedSortFieldsError` when there are discrepancies between the cursor sort options and the original sort options.

For example, the following code will now raise a `MismatchedSortFieldsError` because we set a different field name (`position`) from the `created_at` field used to sort in `scroll`.

```ruby
cursor.field_name = "position" 
Feed::Item.desc(:created_at).scroll(cursor)
```
