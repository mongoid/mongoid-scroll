module Mongoid
  module Scroll
    class Cursor

      attr_accessor :value, :tiebreak_id, :field_type, :field_name, :direction

      def initialize(value = nil, options = {})
        @field_type, @field_name = Mongoid::Scroll::Cursor.extract_field_options(options)
        @direction = options[:direction] || '$gt'
        parse(value)
      end

      def criteria
        cursor_criteria = { field_name => { direction => value } } if value
        tiebreak_criteria = { field_name => value, :_id => { '$gt' => tiebreak_id } } if value && tiebreak_id
        (cursor_criteria || tiebreak_criteria) ? { '$or' => [ cursor_criteria, tiebreak_criteria].compact } : {}
      end

      class << self
        def from_record(record, options)
          cursor = Mongoid::Scroll::Cursor.new(nil, options)
          cursor.value = Mongoid::Scroll::Cursor.parse_field_value(cursor.field_type, cursor.field_name, record.send(cursor.field_name))
          cursor.tiebreak_id = record.id
          cursor
        end
      end

      def to_s
        tiebreak_id ? [ Mongoid::Scroll::Cursor.transform_field_value(field_type, field_name, value), tiebreak_id ].join(":") : nil
      end

      private

        def parse(value)
          return unless value
          parts = value.split(":")
          unless parts.length >= 2
            raise Mongoid::Scroll::Errors::InvalidCursorError.new({ cursor: value })
          end
          id = parts[-1]
          value = parts[0...-1].join(":")
          @value = Mongoid::Scroll::Cursor.parse_field_value(field_type, field_name, value)
          @tiebreak_id = Moped::BSON::ObjectId(id)
        end

        class << self

          def extract_field_options(options)
            if options && (field_name = options[:field_name]) && (field_type = options[:field_type])
              [ field_type, field_name ]
            elsif options && (field = options[:field])
              [ field.type, field.name ]
            else
              raise ArgumentError.new "Missing options[:field_name] and/or options[:field_type]."
            end
          end

          def parse_field_value(field_type, field_name, value)
            case field_type.to_s
            when "String" then value.to_s
            when "DateTime" then Time.at(value.to_i).to_datetime
            when "Time" then Time.at(value.to_i)
            when "Date" then Time.at(value.to_i).utc.to_date
            when "Float" then value.to_f
            when "Integer" then value.to_i
            else
              raise Mongoid::Scroll::Errors::UnsupportedFieldTypeError.new(field: field_name, type: field_type)
            end
          end

          def transform_field_value(field_type, field_name, value)
            case field_type.to_s
            when "String" then value.to_s
            when "Date" then value.to_time(:utc).to_i
            when "DateTime", "Time" then value.to_i
            when "Float" then value.to_f
            when "Integer" then value.to_i
            else
              raise Mongoid::Scroll::Errors::UnsupportedFieldTypeError.new(field: field_name, type: field_type)
            end
          end

        end

    end
  end
end
