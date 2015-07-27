module Feed
  class EmbeddedItem
    include Mongoid::Document

    field :name, type: String

    embedded_in :item, inverse_of: :embedded_items
  end
end
