module Mongoid
  module Scroll
    class BaseCursor
      attr_accessor :value, :tiebreak_id, :field_type, :field_name, :direction, :include_current

      def initialize(value, options = {})
        @value = value
        @tiebreak_id = options[:tiebreak_id]
        @field_type = options[:field_type]
        @field_name = options[:field_name]
        @direction = options[:direction] || 1
        @include_current = options[:include_current] || false
      end

      def criteria
        mongo_value = value.class.mongoize(value) if value
        cursor_criteria = { field_name => { compare_direction => mongo_value } } if mongo_value
        tiebreak_criteria = { field_name => mongo_value, :_id => { tiebreak_compare_direction => tiebreak_id } } if mongo_value && tiebreak_id
        cursor_selector = if Mongoid::Compatibility::Version.mongoid6? || Mongoid::Compatibility::Version.mongoid7?
                            Mongoid::Criteria::Queryable::Selector.new
                          else
                            Origin::Selector.new
                          end
        cursor_selector['$or'] = [cursor_criteria, tiebreak_criteria].compact if cursor_criteria || tiebreak_criteria
        cursor_selector.__evolve_object_id__
      end

      def sort_options
        {
          field_type: field_type,
          field_name: field_name,
          direction: direction
        }
      end

      def to_s
        raise NotImplementedError.new(:to_s)
      end

      private

      def compare_direction
        direction == 1 ? '$gt' : '$lt'
      end

      def tiebreak_compare_direction
        if include_current
          case compare_direction
          when '$gt'
            '$gte'
          when '$lt'
            '$lte'
          end
        else
          compare_direction
        end
      end

      def parse(_value)
        raise NotImplementedError.new(:parse)
      end

      def string_to_id(value)
        return unless value && !value.empty?
        if Mongoid::Compatibility::Version.mongoid3?
          Moped::BSON::ObjectId(value)
        else
          BSON::ObjectId.from_string(value)
        end
      end
    end
  end
end
