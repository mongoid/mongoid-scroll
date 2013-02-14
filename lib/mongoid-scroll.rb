require 'i18n'

I18n.load_path << File.join(File.dirname(__FILE__), "config", "locales", "en.yml")

require 'mongoid/scroll/version'
require 'mongoid/scroll/errors'
