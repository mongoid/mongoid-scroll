source "http://rubygems.org"

gemspec

case version = ENV['MONGOID_VERSION'] || '~> 4.0'
when /4/
  gem 'mongoid', '~> 4.0'
when /3/
  gem 'mongoid', '~> 3.1'
else
  gem 'mongoid', version
end

group :development, :test do
  gem "rake"
  gem "bundler"
  gem "rspec", "~> 3.0"
  gem "rspec-its"
  gem "faker"
  gem "rubocop", "0.24.0"
end
