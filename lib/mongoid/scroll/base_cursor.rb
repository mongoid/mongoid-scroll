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

      class << self
        def parse_field_value(field_type, field_name, value)
          return nil unless value

          case field_type.to_s
          when 'BSON::ObjectId' then BSON::ObjectId.from_string(value)
          when 'String' then value.to_s == '' ? nil : value.to_s
          when 'DateTime' then value.is_a?(DateTime) ? value : Time.at(value.to_i).to_datetime
          when 'Time' then value.is_a?(Time) ? value : Time.at(value.to_i)
          when 'Date' then value.is_a?(Date) ? value : Time.at(value.to_i).utc.to_date
          when 'Float' then value.to_f
          when 'Integer' then value.to_i
          else
            raise Mongoid::Scroll::Errors::UnsupportedFieldTypeError.new(field: field_name, type: field_type)
          end
        end

        def transform_field_value(field_type, field_name, value)
          return nil unless value

          case field_type.to_s
          when 'BSON::ObjectId' then value.to_s
          when 'String' then value.to_s
          when 'Date' then Time.utc(value.year, value.month, value.day).to_i
          when 'DateTime', 'Time' then value.utc.to_i
          when 'Float' then value.to_f
          when 'Integer' then value.to_i
          else
            raise Mongoid::Scroll::Errors::UnsupportedFieldTypeError.new(field: field_name, type: field_type)
          end
        end

        def from_record(record, options)
          cursor = new(nil, options)
          record_value = record.respond_to?(cursor.field_name) ? record.send(cursor.field_name) : record[cursor.field_name]
          cursor.value = Mongoid::Scroll::BaseCursor.parse_field_value(cursor.field_type, cursor.field_name, record_value)
          cursor.tiebreak_id = record['_id']
          cursor
        end

        def extract_field_options(options)
          if options && (field_name = options[:field_name]) && (field_type = options[:field_type])
            {
              field_type: field_type.to_s,
              field_name: field_name.to_s,
              direction: options[:direction] || 1,
              include_current: options[:include_current] || false
            }
          elsif options && (field = options[:field])
            {
              field_type: field.type.to_s,
              field_name: field.name.to_s,
              direction: options[:direction] || 1,
              include_current: options[:include_current] || false
            }
          end
        end
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
    end
  end
end
