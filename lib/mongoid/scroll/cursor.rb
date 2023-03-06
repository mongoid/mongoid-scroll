module Mongoid
  module Scroll
    class Cursor < BaseCursor
      def initialize(value = nil, options = {})
        options = BaseCursor.extract_field_options(options)
        raise ArgumentError.new 'Missing options[:field_name] and/or options[:field_type].' unless options
        if value
          parts = value.split(':') if value
          unless parts && parts.length >= 2
            raise Mongoid::Scroll::Errors::InvalidCursorError.new(cursor: value)
          end
          value = Mongoid::Scroll::BaseCursor.parse_field_value(
            options[:field_type],
            options[:field_name],
            parts[0...-1].join(':')
          )
          options[:tiebreak_id] = BSON::ObjectId.from_string(parts[-1])
          super value, options
        else
          super nil, options
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
    end
  end
end
