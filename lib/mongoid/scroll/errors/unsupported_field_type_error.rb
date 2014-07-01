module Mongoid
  module Scroll
    module Errors
      class UnsupportedFieldTypeError < Mongoid::Scroll::Errors::Base
        def initialize(opts = {})
          super(compose_message('unsupported_field_type', opts))
        end
      end
    end
  end
end
