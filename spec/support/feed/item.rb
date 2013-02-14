module Feed
  class Item
    include Mongoid::Document

    field :a_integer, type: Integer
    field :a_string, type: String
    field :a_datetime, type: DateTime
    field :a_date, type: Date
    field :a_time, type: Time
    field :a_array, type: Array
  end
end
