module Feed
  class Publisher
    include Mongoid::Document

    field :name, type: String

    has_many :items
  end
end
