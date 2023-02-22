module Mongo
  module Scrollable
    def scroll(cursor = nil, options = nil, cursor_class = Mongoid::Scroll::Cursor, &_block)
      view = self
      # we don't support scrolling over a view with multiple fields
      raise Mongoid::Scroll::Errors::MultipleSortFieldsError.new(sort: view.sort) if view.sort && view.sort.keys.size != 1
      # scroll field and direction
      scroll_field = view.sort ? view.sort.keys.first : :_id
      scroll_direction = view.sort ? view.sort.values.first.to_i : 1
      # scroll cursor from the parameter, with value and tiebreak_id
      options = { field_type: BSON::ObjectId } unless options
      cursor_options = { field_name: scroll_field, direction: scroll_direction }.merge(options)
      cursor = cursor.is_a?(cursor_class) ? cursor : cursor_class.new(cursor, cursor_options)
      # make a view
      view = Mongo::Collection::View.new(
        view.collection,
        view.selector.merge(cursor.criteria),
        sort: (view.sort || {}).merge(_id: scroll_direction),
        skip: skip,
        limit: limit
      )
      # scroll
      if block_given?
        view.each do |record|
          yield record, cursor_class.from_record(record, cursor_options)
        end
      else
        view
      end
    end
  end
end

Mongo::Collection::View.send(:include, Mongo::Scrollable)
