require 'spec_helper'

describe Mongoid::Scroll::Cursor do
  context 'an empty cursor' do
    subject do
      Mongoid::Scroll::Cursor.new nil, field_name: 'a_string', field_type: String
    end
    its(:tiebreak_id) { should be_nil }
    its(:value) { should be_nil }
    its(:criteria) { should eq({}) }
  end
  context 'an invalid cursor' do
    it 'raises InvalidCursorError' do
      expect { Mongoid::Scroll::Cursor.new 'invalid', field_name: 'a_string', field_type: String }.to raise_error Mongoid::Scroll::Errors::InvalidCursorError,
                                                                                                                  /The cursor supplied is invalid: invalid./
    end
  end
  context 'a string field cursor' do
    let(:feed_item) { Feed::Item.create!(a_string: 'astring') }
    subject do
      Mongoid::Scroll::Cursor.new "#{feed_item.a_string}:#{feed_item.id}", field_name: 'a_string', field_type: String
    end
    its(:value) { should eq feed_item.a_string }
    its(:tiebreak_id) { should eq feed_item.id }
    its(:criteria) {
      should eq('$or' => [
        { 'a_string' => { '$gt' => feed_item.a_string } },
        { 'a_string' => feed_item.a_string, :_id => { '$gt' => feed_item.id } }
      ])
    }
  end
  context 'an integer field cursor' do
    let(:feed_item) { Feed::Item.create!(a_integer: 10) }
    subject do
      Mongoid::Scroll::Cursor.new "#{feed_item.a_integer}:#{feed_item.id}", field_name: 'a_integer', field_type: Integer
    end
    its(:value) { should eq feed_item.a_integer }
    its(:tiebreak_id) { should eq feed_item.id }
    its(:criteria) {
      should eq('$or' => [
        { 'a_integer' => { '$gt' => feed_item.a_integer } },
        { 'a_integer' => feed_item.a_integer, :_id => { '$gt' => feed_item.id } }
      ])
    }
  end
  context 'a date/time field cursor' do
    let(:feed_item) { Feed::Item.create!(a_datetime: DateTime.new(2013, 12, 21, 1, 42, 3)) }
    subject do
      Mongoid::Scroll::Cursor.new "#{feed_item.a_datetime.to_i}:#{feed_item.id}", field_name: 'a_datetime', field_type: DateTime
    end
    its(:value) { should eq feed_item.a_datetime }
    its(:tiebreak_id) { should eq feed_item.id }
    its(:to_s) { should eq "#{feed_item.a_datetime.to_i}:#{feed_item.id}" }
    its(:criteria) {
      should eq('$or' => [
        { 'a_datetime' => { '$gt' => feed_item.a_datetime } },
        { 'a_datetime' => feed_item.a_datetime, :_id => { '$gt' => feed_item.id } }
      ])
    }
  end
  context 'a date field cursor' do
    let(:feed_item) { Feed::Item.create!(a_date: Date.new(2013, 12, 21)) }
    subject do
      Mongoid::Scroll::Cursor.new "#{feed_item.a_date.to_datetime.to_i}:#{feed_item.id}", field_name: 'a_date', field_type: Date
    end
    its(:value) { should eq feed_item.a_date }
    its(:tiebreak_id) { should eq feed_item.id }
    its(:to_s) { should eq "#{feed_item.a_date.to_datetime.to_i}:#{feed_item.id}" }
    its(:criteria) {
      should eq('$or' => [
        { 'a_date' => { '$gt' => feed_item.a_date.to_datetime } },
        { 'a_date' => feed_item.a_date.to_datetime, :_id => { '$gt' => feed_item.id } }
      ])
    }
  end
  context 'a time field cursor' do
    let(:feed_item) { Feed::Item.create!(a_time: Time.new(2013, 12, 21, 1, 2, 3)) }
    subject do
      Mongoid::Scroll::Cursor.new "#{feed_item.a_time.to_i}:#{feed_item.id}", field_name: 'a_time', field_type: Time
    end
    its(:value) { should eq feed_item.a_time }
    its(:tiebreak_id) { should eq feed_item.id }
    its(:to_s) { should eq "#{feed_item.a_time.to_i}:#{feed_item.id}" }
    its(:criteria) {
      should eq('$or' => [
        { 'a_time' => { '$gt' => feed_item.a_time } },
        { 'a_time' => feed_item.a_time, :_id => { '$gt' => feed_item.id } }
      ])
    }
  end
  context 'a time field cursor with a field option' do
    let(:feed_item) { Feed::Item.create!(a_time: Time.new(2013, 12, 21, 1, 2, 3)) }
    subject do
      Mongoid::Scroll::Cursor.new "#{feed_item.a_time.to_i}:#{feed_item.id}", field: Feed::Item.fields['a_time']
    end
    its(:value) { should eq feed_item.a_time }
    its(:tiebreak_id) { should eq feed_item.id }
    its(:to_s) { should eq "#{feed_item.a_time.to_i}:#{feed_item.id}" }
    its(:criteria) {
      should eq('$or' => [
        { 'a_time' => { '$gt' => feed_item.a_time } },
        { 'a_time' => feed_item.a_time, :_id => { '$gt' => feed_item.id } }
      ])
    }
  end
  context 'an array field cursor' do
    let(:feed_item) { Feed::Item.create!(a_array: ['x', 'y']) }
    it 'is not supported' do
      expect {
        Mongoid::Scroll::Cursor.from_record feed_item, field_name: 'a_array', field_type: Array
      }.to raise_error Mongoid::Scroll::Errors::UnsupportedFieldTypeError, /The type of the field 'a_array' is not supported: Array./
    end
  end
  context 'an invalid field cursor' do
    it 'raises ArgumentError' do
      expect {
        Mongoid::Scroll::Cursor.new 'invalid:whatever', {}
      }.to raise_error ArgumentError
    end
  end
end
