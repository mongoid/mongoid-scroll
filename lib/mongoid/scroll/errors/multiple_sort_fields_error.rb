module Mongoid
  module Scroll
    module Errors
      class MultipleSortFieldsError < Mongoid::Scroll::Errors::Base

        def initialize(opts = {})
          if opts[:sort] && opts[:sort].is_a?(Hash)
            opts = opts.merge(sort: opts[:sort].keys.join(", "))
          end
          super(compose_message("multiple_sort_fields", opts))
        end

      end
    end
  end
end
