require 'bundler'
Bundler.setup(:default, :development)

require 'mongoid-scroll'
require 'faker'

Mongoid.connect_to 'mongoid_scroll_demo'
Mongoid.purge!

# total items to insert
total_items = 20
# a MongoDB query will be executed every scroll_by items
scroll_by = 7

# insert items with a position out-of-order
rands = (0..total_items).to_a.sort { rand }[0..total_items]
total_items.times do
  Mongoid.default_session['feed_items'].insert(title: Faker::Lorem.sentence, position: rands.pop)
end

Mongoid.default_session['feed_items'].indexes.create(position: 1, _id: 1)

Moped.logger = Logger.new($stdout)
Moped.logger.level = Logger::DEBUG

total_shown = 0
next_cursor = nil
loop do
  current_cursor = next_cursor
  next_cursor = nil
  Mongoid.default_session['feed_items'].find.limit(scroll_by).sort(position: 1).scroll(current_cursor, field_type: Integer, field_name: 'position') do |item, cursor|
    puts "#{item['position']}: #{item['title']}"
    next_cursor = cursor
    total_shown += 1
  end
  break unless next_cursor
  # destroy an item just for the heck of it, scroll is not affected
  item = Mongoid.default_session['feed_items'].find.sort(position: 1).first
  Mongoid.default_session['feed_items'].find(_id: item['_id']).remove
end

# this will be 20
puts "Shown #{total_shown} items."
