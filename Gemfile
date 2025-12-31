source 'http://rubygems.org'

gemspec

case version = ENV['MONGOID_VERSION'] || '~> 7.0'
when 'HEAD' then gem 'mongoid', github: 'mongodb/mongoid'
when /8/    then gem 'mongoid', '~> 8.0'
when /7/    then gem 'mongoid', '~> 7.0'
when /6/    then gem 'mongoid', '~> 6.0'
else gem 'mongoid', version
end

group :development, :test do
  gem 'bundler'
  gem 'coveralls_reborn', require: false
  gem 'danger', require: false
  gem 'danger-changelog', require: false
  gem 'danger-pr-comment', require: false
  gem 'database_cleaner', '~> 1.8.5'
  gem 'faker'
  gem 'rake'
  gem 'rspec', '~> 3.0'
  gem 'rspec-its'
  gem 'rubocop', '1.66.1'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
end
