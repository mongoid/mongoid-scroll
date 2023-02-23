module Mongoid
  module Scroll
    class Cursor
      attr_accessor :value, :tiebreak_id, :field_type, :field_name, :direction, :include_current

      def initialize(value = nil, options = {})
        @field_type, @field_name = Mongoid::Scroll::Cursor.extract_field_options(options)
        @direction = options[:direction] || 1
        @include_current = options[:include_current] || false
        parse(value)
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

      class << self
        def from_record(record, options)
          cursor = Mongoid::Scroll::Cursor.new(nil, options)
          value = record.respond_to?(cursor.field_name) ? record.send(cursor.field_name) : record[cursor.field_name]
          cursor.value = Mongoid::Scroll::Cursor.parse_field_value(cursor.field_type, cursor.field_name, value)
          cursor.tiebreak_id = record['_id']
          cursor
        end
      end

      def to_s
        tiebreak_id ? [Mongoid::Scroll::Cursor.transform_field_value(field_type, field_name, value), tiebreak_id].join(':') : nil
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

      def parse(value)
        return unless value
        parts = value.split(':')
        unless parts.length >= 2
          raise Mongoid::Scroll::Errors::InvalidCursorError.new(cursor: value)
        end
        id = parts[-1]
        value = parts[0...-1].join(':')
        @value = Mongoid::Scroll::Cursor.parse_field_value(field_type, field_name, value)
        @tiebreak_id = if Mongoid::Compatibility::Version.mongoid3?
                         Moped::BSON::ObjectId(id)
                       else
                         BSON::ObjectId.from_string(id)
                       end
      end

      class << self
        def extract_field_options(options)
          if options && (field_name = options[:field_name]) && (field_type = options[:field_type])
            [field_type.to_s, field_name.to_s]
          elsif options && (field = options[:field])
            [field.type.to_s, field.name.to_s]
          else
            raise ArgumentError.new 'Missing options[:field_name] and/or options[:field_type].'
          end
        end

        def parse_field_value(field_type, field_name, value)
          case field_type.to_s
          when 'BSON::ObjectId', 'Moped::BSON::ObjectId' then value
          when 'String' then value.to_s
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
          case field_type.to_s
          when 'BSON::ObjectId', 'Moped::BSON::ObjectId' then value
          when 'String' then value.to_s
          when 'Date' then Time.utc(value.year, value.month, value.day).to_i
          when 'DateTime', 'Time' then value.utc.to_i
          when 'Float' then value.to_f
          when 'Integer' then value.to_i
          else
            raise Mongoid::Scroll::Errors::UnsupportedFieldTypeError.new(field: field_name, type: field_type)
          end
        end
      end
    end
  end
end
