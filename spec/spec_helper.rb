$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'rspec'
require 'rspec/its'
require 'database_cleaner'
require 'mongoid-scroll'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each do |f|
  require f
end

Mongoid.configure do |config|
  config.connect_to 'mongoid_scroll_test'
end

RSpec.configure do |config|
  config.before :all do
    Mongoid.logger.level = Logger::INFO
    Mongo::Logger.logger.level = Logger::INFO if Mongoid::Compatibility::Version.mongoid5? || Mongoid::Compatibility::Version.mongoid6?
  end
  config.before :each do
    DatabaseCleaner.clean
  end
end
