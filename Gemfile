source 'http://rubygems.org'

gemspec

case version = ENV['MONGOID_VERSION'] || '~> 7.0'
when 'HEAD' then gem 'mongoid', github: 'mongodb/mongoid'
when /7/    then gem 'mongoid', '~> 7.0'
when /6/    then gem 'mongoid', '~> 6.0'
when /5/    then gem 'mongoid', '~> 5.0'
when /4/    then gem 'mongoid', '~> 4.0'
when /3/    then gem 'mongoid', '~> 3.1'
else             gem 'mongoid', version
end

group :development, :test do
  gem 'bundler'
  gem 'database_cleaner'
  gem 'faker'
  gem 'mongoid-danger', '~> 0.1.0', require: false
  gem 'rake'
  gem 'rspec', '~> 3.0'
  gem 'rspec-its'
  gem 'rubocop', '0.49.1'
end
