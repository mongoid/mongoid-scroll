module Mongoid
  module Criterion
    module Scrollable
      def scroll(cursor = nil, &_block)
        criteria = self
        # we don't support scrolling over a criteria with multiple fields
        if criteria.options[:sort] && criteria.options[:sort].keys.size != 1
          fail Mongoid::Scroll::Errors::MultipleSortFieldsError.new(sort: criteria.options[:sort])
        elsif !criteria.options.key?(:sort) || criteria.options[:sort].empty?
          # introduce a default sort order if there's none
          criteria = criteria.asc(:_id)
        end
        # scroll field and direction
        scroll_field = criteria.options[:sort].keys.first
        scroll_direction = criteria.options[:sort].values.first.to_i
        # scroll cursor from the parameter, with value and tiebreak_id
        field = criteria.klass.fields[scroll_field.to_s]
        cursor_options = { field_type: field.type, field_name: scroll_field, direction: scroll_direction }
        cursor = cursor.is_a?(Mongoid::Scroll::Cursor) ? cursor : Mongoid::Scroll::Cursor.new(cursor, cursor_options)
        # scroll
        if block_given?
          combo_criteria = criteria.klass.and(criteria.selector, cursor.criteria)
          combo_criteria.options = criteria.options
          combo_criteria.order_by(_id: scroll_direction).each do |record|
            yield record, Mongoid::Scroll::Cursor.from_record(record, cursor_options)
          end
        else
          criteria
        end
      end
    end
  end
end
