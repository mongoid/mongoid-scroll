module Mongoid
  module Scroll
    module Errors
      class NoSuchFieldError < Mongoid::Scroll::Errors::Base
        def initialize(opts = {})
          super(compose_message("no_such_field", opts))
        end
      end
    end
  end
end
