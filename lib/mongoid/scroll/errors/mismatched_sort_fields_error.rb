module Mongoid
  module Scroll
    module Errors
      # Raised when the original sort params and the cursor sort params are different
      class MismatchedSortFieldsError < Mongoid::Scroll::Errors::Base
        def initialize(opts = {})
          opts = opts.merge(diff: opts[:diff].keys.join(', ')) if opts[:diff] && opts[:diff].is_a?(Hash)
          super(compose_message('mismatched_sort_fields', opts))
        end
      end
    end
  end
end
