require 'rubygems'
require 'bundler/gem_tasks'

require File.expand_path('../lib/mongoid/scroll/version', __FILE__)

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :spec
require 'rubocop/rake_task'
Rubocop::RakeTask.new(:rubocop)

task default: [:rubocop, :spec]

