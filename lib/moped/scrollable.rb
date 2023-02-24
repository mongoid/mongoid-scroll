module Moped
  module Scrollable
    def scroll(cursor = nil, options = nil, &_block)
      unless options
        bson_type = Mongoid::Compatibility::Version.mongoid3? ? Moped::BSON::ObjectId : BSON::ObjectId
        options = { field_type: bson_type }
      end
      query = Query.new(collection, operation.selector.dup)
      query.operation.skip = operation.skip
      query.operation.limit = operation.limit
      # we don't support scrolling over a criteria with multiple fields
      if query.operation.selector['$orderby'] && query.operation.selector['$orderby'].keys.size != 1
        raise Mongoid::Scroll::Errors::MultipleSortFieldsError.new(sort: query.operation.selector['$orderby'])
      elsif !query.operation.selector.key?('$orderby') || query.operation.selector['$orderby'].empty?
        # introduce a default sort order if there's none
        query.sort(_id: 1)
      end
      # scroll field and direction
      scroll_field = query.operation.selector['$orderby'].keys.first
      scroll_direction = query.operation.selector['$orderby'].values.first.to_i
      # scroll cursor from the parameter, with value and tiebreak_id
      cursor_options = { field_name: scroll_field.to_s, field_type: options[:field_type].to_s, direction: scroll_direction }
      cursor = cursor.is_a?(Mongoid::Scroll::Cursor) ? cursor : Mongoid::Scroll::Cursor.new(cursor, cursor_options)
      raise_mismatched_sort_fields_error!(cursor, cursor_options) if different_sort_fields?(cursor, cursor_options)
      query.operation.selector['$query'] = query.operation.selector['$query'].merge(cursor.criteria)
      query.operation.selector['$orderby'] = query.operation.selector['$orderby'].merge(_id: scroll_direction)
      # scroll
      if block_given?
        query.each do |record|
          yield record, Mongoid::Scroll::Cursor.from_record(record, cursor_options)
        end
      else
        query
      end
    end

    private

    def raise_mismatched_sort_fields_error!(cursor, criteria_cursor_options)
      diff = cursor.sort_options.reject { |k, v| criteria_cursor_options[k] == v }
      raise Mongoid::Scroll::Errors::MismatchedSortFieldsError.new(diff: diff)
    end

    def different_sort_fields?(cursor, criteria_cursor_options)
      criteria_cursor_options != cursor.sort_options
    end
  end
end

Moped::Query.send(:include, Moped::Scrollable)
