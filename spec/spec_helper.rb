$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'rspec'
require 'rspec/its'
require 'database_cleaner'
require 'mongoid-scroll'

Time.zone ||= 'EST'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each do |f|
  require f
end

Mongoid.configure do |config|
  config.connect_to 'mongoid_scroll_test'
end

RSpec.configure do |config|
  config.before :all do
    Mongoid.logger.level = Logger::INFO
    Mongo::Logger.logger.level = Logger::INFO if Mongoid::Compatibility::Version.mongoid5_or_newer?
  end
  config.before do
    DatabaseCleaner.clean
  end
end
