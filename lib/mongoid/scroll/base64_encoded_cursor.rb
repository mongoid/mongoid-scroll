require 'base64'
require 'json'

module Mongoid
  module Scroll
    # Allows to serializer/deserialize the cursor using RFC 4648
    class Base64EncodedCursor < BaseCursor
      def initialize(value, options = {})
        options = extract_field_options(options)
        if value
          begin
            parsed = ::JSON.parse(::Base64.strict_decode64(value))
          rescue StandardError
            raise Mongoid::Scroll::Errors::InvalidBase64CursorError.new(cursor: value)
          end
          super(parse_field_value(parsed['field_type'], parsed['field_name'], parsed['value']), {
            field_type: parsed['field_type'],
            field_name: parsed['field_name'],
            direction: parsed['direction'],
            include_current: parsed['include_current'],
            tiebreak_id: parsed['tiebreak_id'] && !parsed['tiebreak_id'].empty? ? BSON::ObjectId.from_string(parsed['tiebreak_id']) : nil,
            type: parsed['type'].try(:to_sym)
          })
        else
          super(nil, options)
        end
      end

      def to_s
        Base64.strict_encode64({
          value: transform_field_value(field_type, field_name, value),
          field_type: field_type.to_s,
          field_name: field_name,
          direction: direction,
          include_current: include_current,
          tiebreak_id: tiebreak_id && tiebreak_id.to_s,
          type: type
        }.to_json)
      end
    end
  end
end
