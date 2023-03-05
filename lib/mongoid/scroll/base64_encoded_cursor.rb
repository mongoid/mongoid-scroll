require 'base64'
require 'json'

module Mongoid
  module Scroll
    # Allows to serializer/deserialize the cursor using RFC 4648
    class Base64EncodedCursor < BaseCursor
      def initialize(value, options = {})
        if value
          begin
            parsed = ::JSON.parse(::Base64.strict_decode64(value))
          rescue
            raise Mongoid::Scroll::Errors::InvalidCursorError.new(cursor: value)
          end
          super parsed['value'], {
            field_type: parsed['field_type'],
            field_name: parsed['field_name'],
            direction: parsed['direction'],
            include_current: parsed['include_current'],
            tiebreak_id: string_to_id(parsed['tiebreak_id'])
          }
        else
          super nil, options
        end
      end

      def to_s
        Base64.strict_encode64({
          value: value,
          field_type: field_type,
          field_name: field_name,
          direction: direction,
          include_current: include_current,
          tiebreak_id: tiebreak_id && tiebreak_id.to_s
        }.to_json)
      end
    end
  end
end
