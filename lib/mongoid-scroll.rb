require 'i18n'

I18n.load_path << File.join(File.dirname(__FILE__), 'config', 'locales', 'en.yml')

require 'mongoid'
require 'mongoid/scroll/version'
require 'mongoid/scroll/errors'
require 'mongoid/scroll/base_cursor'
require 'mongoid/scroll/cursor'
require 'mongoid/scroll/base64_encoded_cursor'
require 'mongoid/criteria/scrollable/fields'
require 'mongoid/criteria/scrollable/cursors'
require 'mongoid/criteria/scrollable/iterator'
require 'mongoid/criteria/scrollable'
