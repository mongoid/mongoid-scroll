module Mongoid
  class Criteria
    module Scrollable
      def scroll(cursor = nil, &_block)
        criteria = self
        # we don't support scrolling over a criteria with multiple fields
        if criteria.options[:sort] && criteria.options[:sort].keys.size != 1
          raise Mongoid::Scroll::Errors::MultipleSortFieldsError.new(sort: criteria.options[:sort])
        elsif !criteria.options.key?(:sort) || criteria.options[:sort].empty?
          # introduce a default sort order if there's none
          criteria = criteria.asc(:_id)
        end
        # scroll field and direction
        scroll_field = criteria.options[:sort].keys.first
        scroll_direction = criteria.options[:sort].values.first.to_i
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
    end
  end
end

Mongoid::Criteria.send(:include, Mongoid::Criteria::Scrollable)
