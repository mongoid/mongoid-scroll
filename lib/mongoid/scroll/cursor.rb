module Mongoid
  module Scroll
    class Cursor

      attr_accessor :value, :tiebreak_id, :field, :direction

      def initialize(value = nil, options = {})
        unless options && (@field = options[:field])
          raise ArgumentError.new "Missing options[:field]."
        end
        @direction = options[:direction] || '$gt'
        @value, @tiebreak_id = Mongoid::Scroll::Cursor.parse(value, options)
      end

      def criteria
        cursor_criteria = { field.name => { direction => value } } if value
        tiebreak_criteria = { field.name => value, :_id => { '$gt' => tiebreak_id } } if value && tiebreak_id
        (cursor_criteria || tiebreak_criteria) ? { '$or' => [ cursor_criteria, tiebreak_criteria].compact } : {}
      end

      class << self
        def from_record(record, options)
          unless options && (field = options[:field])
            raise ArgumentError.new "Missing options[:field]."
          end
          Mongoid::Scroll::Cursor.new("#{transform_field_value(field, record.send(field.name))}:#{record.id}", options)
        end
      end

      def to_s
        tiebreak_id ? [ Mongoid::Scroll::Cursor.transform_field_value(field, value), tiebreak_id ].join(":") : nil
      end

      private

        class << self

          def parse(value, options)
            return [ nil, nil ] unless value
            parts = value.split(":")
            unless parts.length >= 2
              raise Mongoid::Scroll::Errors::InvalidCursorError.new({ cursor: value })
            end
            id = parts[-1]
            value = parts[0...-1].join(":")
            [ parse_field_value(options[:field], value), Moped::BSON::ObjectId(id) ]
          end

          def parse_field_value(field, value)
            case field.type.to_s
            when "String" then value.to_s
            when "DateTime" then Time.at(value.to_i).to_datetime
            when "Time" then Time.at(value.to_i)
            when "Date" then Time.at(value.to_i).utc.to_date
            when "Float" then value.to_f
            when "Integer" then value.to_i
            else
              raise Mongoid::Scroll::Errors::UnsupportedFieldTypeError.new(field: field.name, type: field.type)
            end
          end

          def transform_field_value(field, value)
            case field.type.to_s
            when "String" then value.to_s
            when "Date" then value.to_time(:utc).to_i
            when "DateTime", "Time" then value.to_i
            when "Float" then value.to_f
            when "Integer" then value.to_i
            else
              raise Mongoid::Scroll::Errors::UnsupportedFieldTypeError.new(field: field.name, type: field.type)
            end
          end

        end

    end
  end
end
