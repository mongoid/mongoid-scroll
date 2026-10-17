require 'spec_helper'

describe Mongoid::Scroll do
  it 'defines a semantic version' do
    expect(Mongoid::Scroll::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
