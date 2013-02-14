$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'rspec'
require 'mongoid-scroll'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each do |f|
  require f
end

Mongoid.configure do |config|
  config.connect_to 'mongoid_scroll_test'
end

RSpec.configure do |config|
  config.before :each do
    Mongoid.purge!
  end
end

