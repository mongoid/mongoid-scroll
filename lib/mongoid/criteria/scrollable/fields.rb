module Mongoid
  class Criteria
    module Scrollable
      # Shared by *::Scrollable modules
      module Fields
        private

        def scroll_model_field(field_name)
          klass.fields[field_name.to_s] ||
            raise(Mongoid::Scroll::Errors::NoSuchFieldError.new(field: field_name))
        end

        def raise_mismatched_sort_fields_error!(cursor, criteria_cursor_options)
          diff = cursor.sort_options.reject { |k, v| criteria_cursor_options[k] == v }
          raise Mongoid::Scroll::Errors::MismatchedSortFieldsError.new(diff: diff)
        end

        def different_sort_fields?(cursor, criteria_cursor_options)
          scroll_model_field(cursor.field_name)
          criteria_cursor_options[:field_type] = criteria_cursor_options[:field_type].to_s
          criteria_cursor_options[:field_name] = criteria_cursor_options[:field_name].to_s
          criteria_cursor_options != cursor.sort_options
        end
      end
    end
  end
end
