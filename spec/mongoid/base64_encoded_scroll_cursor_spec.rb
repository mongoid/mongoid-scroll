require 'spec_helper'

describe Mongoid::Scroll::Base64EncodedCursor do
  context 'an empty cursor' do
    let(:base64_string) { 'eyJ2YWx1ZSI6bnVsbCwiZmllbGRfdHlwZSI6IlN0cmluZyIsImZpZWxkX25hbWUiOiJhX3N0cmluZyIsImRpcmVjdGlvbiI6MSwiaW5jbHVkZV9jdXJyZW50IjpmYWxzZX0=' }
    subject do
      described_class.new(base64_string)
    end
    its(:tiebreak_id) { should be_nil }
    its(:value) { should be_nil }
    its(:criteria) { should eq({}) }
    its(:to_s) { should eq(base64_string) }

    describe '.from_cursor' do
      let(:base_cursor) { Mongoid::Scroll::Cursor.new nil, field_name: 'a_string', field_type: String }
      it 'is properly created' do
        base64_encoded_cursor = described_class.from_cursor(base_cursor)
        expect(base64_encoded_cursor).to be_a(described_class)
        expect(base64_encoded_cursor.tiebreak_id).to be_nil
        expect(base64_encoded_cursor.value).to be_nil
        expect(base64_encoded_cursor.criteria).to eq({})
      end
    end
  end

  context 'a string field cursor' do
    let(:base64_string) { 'eyJ2YWx1ZSI6ImFzdHJpbmc6NjQwMjBjYzA4OWIyNTQ0ZTIzYTdkNmRjIiwiZmllbGRfdHlwZSI6IlN0cmluZyIsImZpZWxkX25hbWUiOiJhX3N0cmluZyIsImRpcmVjdGlvbiI6MSwiaW5jbHVkZV9jdXJyZW50IjpmYWxzZX0=' }
    let(:feed_item) { Feed::Item.create!(id: '64020cc089b2544e23a7d6dc', a_string: 'astring') }
    let(:criteria) do
      {
        '$or' => [
          { 'a_string' => { '$gt' => feed_item.a_string } },
          { 'a_string' => feed_item.a_string, '_id' => { '$gt' => feed_item.id } }
        ]
      }
    end
    subject do
      described_class.new(base64_string)
    end
    its(:value) { should eq feed_item.a_string }
    its(:tiebreak_id) { should eq feed_item.id }
    its(:criteria) do
      should eq(criteria)
    end
    its(:to_s) { should eq(base64_string) }

    describe '.from_cursor' do
      let(:base_cursor) { Mongoid::Scroll::Cursor.new "#{feed_item.a_string}:#{feed_item.id}", field_name: 'a_string', field_type: String }
      it 'is properly created' do
        base64_encoded_cursor = described_class.from_cursor(base_cursor)
        expect(base64_encoded_cursor).to be_a(described_class)
        expect(base64_encoded_cursor.tiebreak_id).to eq(feed_item.id)
        expect(base64_encoded_cursor.value).to eq('astring')
        expect(base64_encoded_cursor.criteria).to eq(criteria)
      end
    end
  end

  context 'an invalid cursor' do
    it 'raises a Mongoid::Scroll::Errors::InvalidCursorError with an invalid Base64 string' do
      expect { described_class.new 'invalid' }.to raise_error Mongoid::Scroll::Errors::InvalidCursorError, /The cursor supplied is invalid: invalid./
    end

    it 'raises a Mongoid::Scroll::Errors::InvalidCursorError with an invalid JSON string' do
      expect { described_class.new 'aW52YWxpZA==' }.to raise_error Mongoid::Scroll::Errors::InvalidCursorError, /The cursor supplied is invalid: aW52YWxpZA==./
    end
  end
end
