module Mongoid
  module Scroll
    module Errors
      class UnsupportedTypeError < Mongoid::Scroll::Errors::Base
        def initialize(opts = {})
          super(compose_message('unsupported_type', opts))
        end
      end
    end
  end
end
