require 'spec_helper'

describe Mongoid::Scroll do
  it 'loads a standalone semantic version' do
    stub_const('Mongoid::Scroll', Module.new)
    load File.expand_path('../../lib/mongoid/scroll/version.rb', __dir__)
    expect(Mongoid::Scroll::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
