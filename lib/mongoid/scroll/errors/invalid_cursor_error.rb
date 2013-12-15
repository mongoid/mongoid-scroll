module Mongoid
  module Scroll
    module Errors
      class InvalidCursorError < Mongoid::Scroll::Errors::Base
        def initialize(opts = {})
          super(compose_message("invalid_cursor", opts))
        end
      end
    end
  end
end
