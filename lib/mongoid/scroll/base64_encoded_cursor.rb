require 'base64'
require 'json'

module Mongoid
  module Scroll
    # Allows to serialize/deserialize the cursor using RFC 4648
    class Base64EncodedCursor < Cursor
      def to_s
        Base64.strict_encode64({ value: super, field_type: field_type, field_name: field_name, direction: direction }.to_json)
      end

      class << self
        def deserialize(str)
          config_hash = ::JSON.parse(::Base64.strict_decode64(str))
          new(config_hash['value'], field_type: config_hash['field_type'], field_name: config_hash['field_name'], direction: config_hash['direction'])
        rescue ArgumentError
          raise Mongoid::Scroll::Errors::InvalidBase64Error.new(str: str)
        end
      end
    end
  end
end
