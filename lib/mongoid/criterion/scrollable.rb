module Mongoid
  module Criterion
    module Scrollable

      def scroll(cursor = nil, &block)
        c = self
        # we don't support scrolling over a criteria with multiple fields
        if c.options[:sort] && c.options[:sort].keys.count != 1
          sort = c.options[:sort].keys.join(", ")
          raise Mongoid::Scroll::Errors::MultipleSortFieldsError.new(sort: sort)
        end
        # introduce a default sort order if there's none
        c = c.asc(:_id) if (! c.options[:sort]) || c.options[:sort].empty?
        # scroll field and direction
        scroll_field = c.options[:sort].keys.first
        scroll_direction = c.options[:sort].values.first.to_i == 1 ? '$gt' : '$lt'
        # scroll cursor from the parameter, with value and tiebreak_id
        field = c.klass.fields[scroll_field.to_s]
        cursor = Mongoid::Scroll::Cursor.new(cursor, { field: field, direction: scroll_direction })
        # scroll
        if block_given?
          c.where(cursor.criteria).each do |record|
            yield record, Mongoid::Scroll::Cursor.from_record(field, record)
          end
        else
          c
        end
      end

    end
  end
end
