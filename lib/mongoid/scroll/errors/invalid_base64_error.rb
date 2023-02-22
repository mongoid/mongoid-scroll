module Mongoid
  module Scroll
    module Errors
      # Raised when a string expected to be encoded in Base64 (following RFC 4648) is invalid
      class InvalidBase64Error < Mongoid::Scroll::Errors::Base
        def initialize(opts = {})
          super(compose_message('invalid_base64', opts))
        end
      end
    end
  end
end
