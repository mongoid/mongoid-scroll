module Mongoid
  module Scroll
    def self.mongoid3?
      ::Mongoid.const_defined? :Observer
    end
  end
end
