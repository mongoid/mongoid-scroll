module Mongoid
  module Scroll
    module Errors
      class InvalidBase64CursorError < InvalidBaseCursorError
        def initialize(opts = {})
          super(compose_message('invalid_base64_cursor', opts))
        end
      end
    end
  end
end
