module Mongoid
  module Scroll
    module Errors
      class MultipleSortFieldsError < Mongoid::Scroll::Errors::Base
        def initialize(opts = {})
          opts = opts.merge(sort: opts[:sort].keys.join(', ')) if opts[:sort] && opts[:sort].is_a?(Hash)
          super(compose_message('multiple_sort_fields', opts))
        end
      end
    end
  end
end
