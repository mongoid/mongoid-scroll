module Mongo
  module Scrollable
    include Mongoid::Criteria::Scrollable::Fields
    include Mongoid::Criteria::Scrollable::Cursors

    def scroll(cursor_or_type = nil, options = nil, &_block)
      cursor, cursor_type = cursor_and_type(cursor_or_type)
      view = self
      # we don't support scrolling over a view with multiple fields
      raise Mongoid::Scroll::Errors::MultipleSortFieldsError.new(sort: view.sort) if view.sort && view.sort.keys.size != 1
      # scroll field and direction
      scroll_field = view.sort ? view.sort.keys.first : :_id
      scroll_direction = view.sort ? view.sort.values.first.to_i : 1
      # scroll cursor from the parameter, with value and tiebreak_id
      options = { field_type: BSON::ObjectId } unless options
      cursor_options = { field_name: scroll_field, direction: scroll_direction }.merge(options)
      cursor = cursor && cursor.is_a?(cursor_type) ? cursor : cursor_type.new(cursor, cursor_options)
      raise_mismatched_sort_fields_error!(cursor, cursor_options) if different_sort_fields?(cursor, cursor_options)

      records = nil
      if cursor.type == :previous
        # scroll backwards by reversing the sort order, limit and then reverse again
        pipeline = [
          { '$match' => view.selector.merge(cursor.criteria) },
          { '$sort' => { scroll_field => -scroll_direction } },
          { '$limit' => limit },
          { '$sort' => { scroll_field => scroll_direction } }
        ]
        aggregation_options = view.options.except(:sort)
        records = view.aggregate(pipeline, aggregation_options)
      else
        # make a view
        records = Mongo::Collection::View.new(
          view.collection,
          view.selector.merge(cursor.criteria),
          sort: (view.sort || {}).merge(_id: scroll_direction),
          skip: skip,
          limit: limit
        )
      end
      # scroll
      if block_given?
        previous_cursor = nil
        current_cursor = nil
        records.each do |record|
          previous_cursor ||= cursor_type.from_record(record, cursor_options.merge(type: :previous))
          current_cursor ||= cursor_type.from_record(record, cursor_options.merge(include_current: true))
          iterator = Mongoid::Criteria::Scrollable::Iterator.new(
            previous_cursor: previous_cursor,
            next_cursor: cursor_type.from_record(record, cursor_options),
              current_cursor: current_cursor
          )
          yield record, iterator
        end
      else
        records
      end
    end
  end
end

Mongo::Collection::View.send(:include, Mongo::Scrollable)
