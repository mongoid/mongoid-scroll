# Upgrading

## Upgrading to >= 1.0.0

### Mismatched Sort Fields

`Mongoid::Criteria::Scrollable#scroll`, `Moped::Scrollable` and `Mongo::Scrollable` now raise a `Mongoid::Scroll::Errors::MismatchedSortFieldsError` when there are discrepancies between the cursor sort options and the original sort options.
Make sure to avoid this case or to handle the new exception.
