module Mongoid
  module Scroll
    module Errors
      # Raised when the original sort params and the cursor sort params are different
      class DifferentSortFieldsError < Mongoid::Scroll::Errors::Base
        def initialize(opts = {})
          if opts[:diff] && opts[:diff].is_a?(Hash)
            opts = opts.merge(diff: opts[:diff].keys.join(', '))
          end
          super(compose_message('different_sort_fields', opts))
        end
      end
    end
  end
end
