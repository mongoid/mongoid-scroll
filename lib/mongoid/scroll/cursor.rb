module Mongoid
  module Scroll
    class Cursor < BaseCursor
      def initialize(value = nil, options = {})
        options = Mongoid::Scroll::Cursor.extract_field_options(options)
        if value
          parts = value.split(':') if value
          unless parts && parts.length >= 2
            raise Mongoid::Scroll::Errors::InvalidCursorError.new(cursor: value)
          end
          value = Mongoid::Scroll::Cursor.parse_field_value(
            options[:field_type],
            options[:field_name],
            parts[0...-1].join(':')
          )
          options[:tiebreak_id] = string_to_id(parts[-1])
          super value, options
        else
          super nil, options
        end
      end

      class << self
        def from_record(record, options)
          cursor = new(nil, options)
          record_value = record.respond_to?(cursor.field_name) ? record.send(cursor.field_name) : record[cursor.field_name]
          cursor.value = Mongoid::Scroll::Cursor.parse_field_value(cursor.field_type, cursor.field_name, record_value)
          cursor.tiebreak_id = record['_id']
          cursor
        end
      end

      def to_s
        tiebreak_id ? [
          Mongoid::Scroll::Cursor.transform_field_value(
            field_type,
            field_name,
            value
          ), tiebreak_id
        ].join(':') : nil
      end

      private

      class << self
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
          elsif self == Mongoid::Scroll::Cursor
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
