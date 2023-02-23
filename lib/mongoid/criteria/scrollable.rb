module Mongoid
  class Criteria
    module Scrollable
      def scroll(cursor = nil, &_block)
        raise_multiple_sort_fields_error if multiple_sort_fields?
        criteria = dup
        criteria.merge!(default_sort) if no_sort_option?
        cursor_options = build_cursor_options(criteria)
        cursor = cursor.is_a?(Mongoid::Scroll::Cursor) ? cursor : new_cursor(cursor, cursor_options)
        raise_different_sort_fields_error!(cursor, cursor_options) if different_sort_fields?(cursor, cursor_options)
        cursor_criteria = build_cursor_criteria(criteria, cursor)
        if block_given?
          cursor_criteria.order_by(_id: scroll_direction(criteria)).each do |record|
            yield record, cursor_from_record(record, cursor_options)
          end
        else
          cursor_criteria
        end
      end

      private

      def raise_multiple_sort_fields_error
        raise Mongoid::Scroll::Errors::MultipleSortFieldsError.new(sort: criteria.options.sort)
      end

      def raise_different_sort_fields_error!(cursor, criteria_cursor_options)
        diff = cursor.sort_options.reject { |k, v| criteria_cursor_options[k] == v }
        raise Mongoid::Scroll::Errors::DifferentSortFieldsError.new(diff: diff)
      end

      def multiple_sort_fields?
        options.sort && options.sort.keys.size != 1
      end

      def no_sort_option?
        options.sort.blank? || options.sort.empty?
      end

      def different_sort_fields?(cursor, criteria_cursor_options)
        criteria_cursor_options != cursor.sort_options
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

      def build_cursor_options(criteria)
        {
          field_type: scroll_field_type(criteria),
          field_name: scroll_field(criteria),
          direction: scroll_direction(criteria)
        }
      end

      def new_cursor(cursor, cursor_options)
        Mongoid::Scroll::Cursor.new(cursor, cursor_options)
      end

      def build_cursor_criteria(criteria, cursor)
        cursor_criteria = criteria.dup
        cursor_criteria.selector = { '$and' => [criteria.selector, cursor.criteria] }
        cursor_criteria
      end

      def cursor_from_record(record, cursor_options)
        Mongoid::Scroll::Cursor.from_record(record, cursor_options)
      end

      def scroll_field_type(criteria)
        scroll_field = scroll_field(criteria)
        field = criteria.klass.fields[scroll_field.to_s]
        field.foreign_key? && field.object_id_field? ? bson_type.to_s : field.type.to_s
      end

      def bson_type
        Mongoid::Compatibility::Version.mongoid3? ? Moped::BSON::ObjectId : BSON::ObjectId
      end
    end
  end
end

Mongoid::Criteria.send(:include, Mongoid::Criteria::Scrollable)
