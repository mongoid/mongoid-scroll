source 'https://rubygems.org'

gemspec

case version = ENV['MONGOID_VERSION'] || '9'
when 'HEAD' then gem 'mongoid', github: 'mongodb/mongoid'
when /^9/ then gem 'mongoid', '~> 9.0'
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
  gem 'json', '< 3' # Older ActiveSupport passes the quirks_mode option that json 3 removed.
  gem 'logger'
  gem 'mutex_m'
  gem 'rake'
  gem 'rspec', '~> 3.0'
  gem 'rspec-its'
  gem 'simplecov', '>= 0.22', require: false
  if RUBY_ENGINE == 'ruby' && Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.3')
    gem 'commonmarker', '~> 2.10', require: false
    gem 'rubocop', '~> 1.92'
    gem 'rubocop-md', '~> 3.0', require: false
    gem 'rubocop-prose', '~> 0.2', require: false
    gem 'rubocop-rake', '~> 0.7', require: false
    gem 'rubocop-rspec', '~> 3.10', require: false
    gem 'rubocop-spellcheck', '~> 0.2', require: false
    gem 'rubocop-yaml', '~> 0.1.0', require: false
    gem 'ruby-gem-release', '0.9.0', require: false
  end
end
