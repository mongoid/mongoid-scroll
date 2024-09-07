$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'mongoid/scroll/version'

Gem::Specification.new do |s|
  s.name = 'mongoid-scroll'
  s.version = Mongoid::Scroll::VERSION
  s.authors = ['Daniel Doubrovkine', 'Frank Macreery']
  s.email = 'dblock@dblock.org'
  s.platform = Gem::Platform::RUBY
  s.required_rubygems_version = '>= 1.3.6'
  s.files = `git ls-files`.split("\n")
  s.require_paths = ['lib']
  s.homepage = 'http://github.com/mongoid/mongoid-scroll'
  s.licenses = ['MIT']
  s.summary = 'Mongoid extensions to enable infinite scroll.'
  s.add_dependency 'i18n'
  s.add_dependency 'mongoid', '>= 6.0'
  s.metadata['rubygems_mfa_required'] = 'true'
end
