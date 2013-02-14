require 'spec_helper'

describe Mongoid::Scroll::Cursor do
  context "an empty cursor" do
    subject do
      Mongoid::Scroll::Cursor.new(nil, { field: Feed::Item.fields["a_string"]})
    end
    its(:tiebreak_id) { should be_nil }
    its(:value) { should be_nil }
    its(:criteria) { should eq({}) }
  end
  context "an invalid cursor" do
    it "raises InvalidCursorError" do
      expect { Mongoid::Scroll::Cursor.new "invalid", field: Feed::Item.fields["a_string"] }.to raise_error Mongoid::Scroll::Errors::InvalidCursorError,
        /The cursor supplied is invalid: invalid./
    end
  end
  context "a string field cursor" do
    let(:feed_item) { Feed::Item.create!(a_string: "astring") }
    subject do
      Mongoid::Scroll::Cursor.new "#{feed_item.a_string}:#{feed_item.id}", field: Feed::Item.fields["a_string"]
    end
    its(:value) { should eq feed_item.a_string }
    its(:tiebreak_id) { should eq feed_item.id }
    its(:criteria) {
      should eq({ "$or" => [
        { "a_string" => { "$gt" => feed_item.a_string }},
        { "a_string" => feed_item.a_string, :_id => { "$gt" => feed_item.id }}
      ]})
    }
  end
  context "an integer field cursor" do
    let(:feed_item) { Feed::Item.create!(a_integer: 10) }
    subject do
      Mongoid::Scroll::Cursor.new "#{feed_item.a_integer}:#{feed_item.id}", field: Feed::Item.fields["a_integer"]
    end
    its(:value) { should eq feed_item.a_integer }
    its(:tiebreak_id) { should eq feed_item.id }
    its(:criteria) {
      should eq({ "$or" => [
        { "a_integer" => { "$gt" => feed_item.a_integer }},
        { "a_integer" => feed_item.a_integer, :_id => { "$gt" => feed_item.id }}
      ]})
    }
  end
  context "a date/time field cursor" do
    let(:feed_item) { Feed::Item.create!(a_datetime: DateTime.new(2013, 12, 21, 1, 42, 3)) }
    subject do
      Mongoid::Scroll::Cursor.new "#{feed_item.a_datetime}:#{feed_item.id}", field: Feed::Item.fields["a_datetime"]
    end
    its(:value) { should eq feed_item.a_datetime }
    its(:tiebreak_id) { should eq feed_item.id }
    its(:criteria) {
      should eq({ "$or" => [
        { "a_datetime" => { "$gt" => feed_item.a_datetime }},
        { "a_datetime" => feed_item.a_datetime, :_id => { "$gt" => feed_item.id }}
      ]})
    }
  end
  context "an invalid field cursor" do
    it "raises ArgumentError" do
      expect {
        Mongoid::Scroll::Cursor.new "invalid:whatever", {}
      }.to raise_error ArgumentError
    end
  end
end
