module Mongoid
  module Scroll
    module Errors
      class MultipleSortFieldsError < Mongoid::Scroll::Errors::Base

        def initialize(opts = {})
          super(compose_message("multiple_sort_fields", opts))
        end

      end
    end
  end
end
