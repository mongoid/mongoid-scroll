module Feed
  class Item
    include Mongoid::Document

    field :name, type: String
    field :a_integer, type: Integer
    field :a_string, type: String
    field :a_datetime, type: DateTime
    field :a_date, type: Date
    field :a_time, type: Time
    field :a_array, type: Array

    embeds_many :embedded_items
    belongs_to :publisher, optional: true
  end
end
