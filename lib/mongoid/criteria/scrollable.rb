module Mongoid
  class Criteria
    module Scrollable
      def scroll(cursor = nil, &_block)
        raise_multiple_sort_fields_error if multiple_sort_fields?
        criteria = dup
        criteria.merge!(default_sort) if no_sort_option?
        scroll_field = scroll_field(criteria)
        scroll_direction = scroll_direction(criteria)
        # scroll cursor from the parameter, with value and tiebreak_id
        field = criteria.klass.fields[scroll_field.to_s]
        cursor_options = { field_type: type_from_field(field), field_name: scroll_field, direction: scroll_direction }
        cursor = cursor.is_a?(Mongoid::Scroll::Cursor) ? cursor : Mongoid::Scroll::Cursor.new(cursor, cursor_options)
        cursor_criteria = criteria.dup
        cursor_criteria.selector = { '$and' => [criteria.selector, cursor.criteria] }
        # scroll
        if block_given?
          cursor_criteria.order_by(_id: scroll_direction).each do |record|
            yield record, Mongoid::Scroll::Cursor.from_record(record, cursor_options)
          end
        else
          cursor_criteria
        end
      end

      def type_from_field(field)
        bson_type = Mongoid::Compatibility::Version.mongoid3? ? Moped::BSON::ObjectId : BSON::ObjectId
        field.foreign_key? && field.object_id_field? ? bson_type : field.type
      end

      private
      def multiple_sort_fields?
        options.sort && options.sort.keys.size != 1
      end

      def no_sort_option?
        options.sort.blank? || options.sort.empty?
      end

      def default_sort
        asc(:_id)
      end

      def scroll_field(criteria)
        criteria.options.sort.keys.first
      end

      def scroll_direction(criteria)
        criteria.options.sort.values.first.to_i
      end

      def raise_multiple_sort_fields_error
        raise Mongoid::Scroll::Errors::MultipleSortFieldsError.new(sort: criteria.options[:sort])
      end
    end
  end
end

Mongoid::Criteria.send(:include, Mongoid::Criteria::Scrollable)
