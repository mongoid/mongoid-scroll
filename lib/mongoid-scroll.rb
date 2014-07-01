require 'i18n'

I18n.load_path << File.join(File.dirname(__FILE__), 'config', 'locales', 'en.yml')

require 'mongoid'
require 'mongoid/scroll/version'
require 'mongoid/scroll/mongoid'
require 'mongoid/scroll/errors'
require 'mongoid/scroll/cursor'

require 'moped/scrollable'
require 'mongoid/criterion/scrollable'

Moped::Query.send(:include, Moped::Scrollable)
Mongoid::Criteria.send(:include, Mongoid::Criterion::Scrollable)
