module Mongoid
  class Criteria
    module Scrollable
      # Shared by *::Scrollable modules
      module Cursors
        private

        def cursor_and_type(cursor_or_type)
          cursor = cursor_or_type.is_a?(Class) ? nil : cursor_or_type
          cursor_type = cursor_or_type.is_a?(Class) ? cursor_or_type : nil
          cursor_type ||= cursor.class if cursor.is_a?(Mongoid::Scroll::BaseCursor)
          cursor_type ||= Mongoid::Scroll::Cursor
          [cursor, cursor_type]
        end
      end
    end
  end
end
