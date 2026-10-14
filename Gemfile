source 'https://rubygems.org'

gemspec

case version = ENV['MONGOID_VERSION'] || '9'
when 'HEAD' then gem 'mongoid', github: 'mongodb/mongoid'
when /^9/  then gem 'mongoid', '~> 9.0'
when /8/    then gem 'mongoid', '~> 8.0'
when /7/    then gem 'mongoid', '~> 7.0'
when /6/    then gem 'mongoid', '~> 6.0'
else gem 'mongoid', version
end

group :development, :test do
  gem 'base64'
  gem 'benchmark'
  gem 'bigdecimal'
  gem 'bundler'
  gem 'danger', require: false
  gem 'danger-changelog', require: false
  gem 'danger-pr-comment', require: false
  gem 'database_cleaner-mongoid', '~> 2.0'
  gem 'faker'
  gem 'logger'
  gem 'mutex_m'
  gem 'rake'
  gem 'rspec', '~> 3.0'
  gem 'rspec-its'
  gem 'simplecov', '>= 0.22', require: false
  gem 'rubocop', '1.66.1'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
end
