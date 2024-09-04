module Mongoid
  class Criteria
    module Scrollable
      class Iterator
        attr_accessor :previous_cursor, :next_cursor

        def initialize(previous_cursor:, next_cursor:)
          @previous_cursor = previous_cursor
          @next_cursor = next_cursor
        end

        def first_cursor
          @first_cursor ||= next_cursor.class.new(nil, next_cursor.sort_options)
        end
      end
    end
  end
end
