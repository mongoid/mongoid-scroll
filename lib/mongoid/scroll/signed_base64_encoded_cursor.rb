require 'base64'
require 'json'

module Mongoid
  module Scroll
    # Allows to serialize/deserialize the cursor using RFC 4648 and sign it to avoid tampering
    class SignedBase64EncodedCursor < Cursor
      def to_s(&_block)
        config_hash = { value: super, field_type: field_type, field_name: field_name, direction: direction }
        sign = yield(config_hash.to_json)
        config_hash[:sign] = sign
        Base64.strict_encode64(config_hash.to_json)
      end

      class << self
        def deserialize(str, &_block)
          config_hash = ::JSON.parse(::Base64.strict_decode64(str))
          sign = config_hash.delete('sign')
          raise ::Exception.new('Invalid signature') if sign != yield(config_hash.to_json) # TODO: Add custom exception
          new(config_hash['value'], field_type: config_hash['field_type'], field_name: config_hash['field_name'], direction: config_hash['direction'])
        rescue ArgumentError
          raise Mongoid::Scroll::Errors::InvalidBase64Error.new(str: str)
        end
      end
    end
  end
end
