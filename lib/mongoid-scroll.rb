require 'i18n'

I18n.load_path << File.join(File.dirname(__FILE__), 'config', 'locales', 'en.yml')

require 'mongoid'
require 'mongoid-compatibility'
require 'mongoid/scroll/version'
require 'mongoid/scroll/errors'
require 'mongoid/scroll/cursor'
require 'mongoid/scroll/base64_encoded_cursor'
require 'moped/scrollable' if Object.const_defined?(:Moped)
require 'mongo/scrollable' if Object.const_defined?(:Mongo)
require 'mongoid/criteria/scrollable'
