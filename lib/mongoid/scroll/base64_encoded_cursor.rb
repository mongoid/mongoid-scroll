require 'base64'
require 'json'

module Mongoid
  module Scroll
    # Allows to serializer/deserialize the cursor using RFC 4648
    class Base64EncodedCursor < Cursor
      def to_s
        Base64.strict_encode64({ value: super, field_type: field_type, field_name: field_name, direction: direction }.to_json)
      end

      class << self
        def parse(str)
          config_hash = ::JSON.parse(::Base64.strict_decode64(str))
          new(config_hash['value'], field_type: config_hash['field_type'], field_name: config_hash['field_name'], direction: config_hash['direction'])
        rescue ArgumentError
          raise Mongoid::Scroll::Errors::InvalidBase64Error.new(str: str)
        end

        def from_cursor(cursor)
          base64_encoded_cursor = new(nil, field_type: cursor.field_type, field_name: cursor.field_name, direction: cursor.direction)
          base64_encoded_cursor.value = cursor.value
          base64_encoded_cursor.tiebreak_id = cursor.tiebreak_id
          base64_encoded_cursor
        end
      end
    end
  end
end
