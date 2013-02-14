module Moped
  module Scrollable

    def scroll(cursor = nil, options = { field_type: Moped::BSON::ObjectId }, &block)
      # we don't support scrolling over a criteria with multiple fields
      if operation.selector["$orderby"] && operation.selector["$orderby"].keys.size != 1
        raise Mongoid::Scroll::Errors::MultipleSortFieldsError.new(sort: operation.selector["$orderby"])
      elsif ! operation.selector.has_key?("$orderby") || operation.selector["$orderby"].empty?
        # introduce a default sort order if there's none
        sort("_id" => 1)
      end
      # scroll field and direction
      scroll_field = operation.selector["$orderby"].keys.first
      scroll_direction = operation.selector["$orderby"].values.first.to_i == 1 ? '$gt' : '$lt'
      # scroll cursor from the parameter, with value and tiebreak_id
      cursor_options = { field_name: scroll_field, field_type: options[:field_type], direction: scroll_direction }
      cursor = cursor.is_a?(Mongoid::Scroll::Cursor) ? cursor : Mongoid::Scroll::Cursor.new(cursor, cursor_options)
      operation.selector["$query"].merge!(cursor.criteria)
      # scroll
      if block_given?
        each do |record|
          yield record, Mongoid::Scroll::Cursor.from_record(record, cursor_options)
        end
      else
        self
      end
    end

  end
end
