require 'base64'
require 'json'

module Mongoid
  module Scroll
    # Allows to serializer/deserialize the cursor using RFC 4648
    class Base64EncodedCursor < Cursor
      class << self
        def from_cursor(cursor)
          base64_encoded_cursor = new(nil,
                                      field_type: cursor.field_type,
                                      field_name: cursor.field_name,
                                      direction: cursor.direction,
                                      include_current: cursor.include_current)
          base64_encoded_cursor.value = cursor.value
          base64_encoded_cursor.tiebreak_id = cursor.tiebreak_id
          base64_encoded_cursor
        end
      end

      def to_s
        Base64.strict_encode64({ value: super, field_type: field_type, field_name: field_name, direction: direction, include_current: include_current }.to_json)
      end

      private

      def parse(value)
        return unless value

        begin
          config_hash = ::JSON.parse(::Base64.strict_decode64(value))
        rescue
          raise Mongoid::Scroll::Errors::InvalidCursorError.new(cursor: value)
        end
        @field_type = config_hash['field_type']
        @field_name = config_hash['field_name']
        @direction = config_hash['direction']
        @include_current = config_hash['include_current']
        super(config_hash['value'])
      end
    end
  end
end
