module Mongoid
  module Scroll
    def self.mongoid3?
      Mongoid::VERSION =~ /^3\./
    end
  end
end
