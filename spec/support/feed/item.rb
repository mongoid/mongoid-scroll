module Feed
  class Item
    include Mongoid::Document

    field :a_field
    field :a_integer, type: Integer
    field :a_string, type: String
    field :a_datetime, type: DateTime
  end
end
