require 'bundler'
Bundler.setup(:default, :development)

require 'mongoid-scroll'
require 'faker'

Mongoid.connect_to "mongoid_scroll_demo"
Mongoid.purge!

module Feed
  class Item
    include Mongoid::Document
    field :title, type: String
    field :position, type: Integer
    index(position: 1, _id: 1)
  end
end

# total items to insert
total_items = 20
# a MongoDB query will be executed every scroll_by items
scroll_by = 7

# insert items with a position out-of-order
rands = (0..total_items).to_a.sort { rand }[0..total_items]
total_items.times do |i|
  Feed::Item.create! title: Faker::Lorem.sentence, position: rands.pop
end

Moped.logger = Logger.new($stdout)
Moped.logger.level = Logger::DEBUG

Feed::Item.create_indexes

total_shown = 0
next_cursor = nil
loop do
  current_cursor = next_cursor
  next_cursor = nil
  Feed::Item.asc(:position).limit(scroll_by).scroll(current_cursor) do |item, cursor|
    puts "#{item.position}: #{item.title}"
    next_cursor = cursor
    total_shown += 1
  end
  break unless next_cursor
  # destroy an item just for the heck of it, scroll is not affected
  Feed::Item.asc(:position).first.destroy
end

# this will be 20
puts "Shown #{total_shown} items."
