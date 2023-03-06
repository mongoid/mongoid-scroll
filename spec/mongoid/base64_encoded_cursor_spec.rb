require 'spec_helper'

describe Mongoid::Scroll::Base64EncodedCursor do
  context 'an empty cursor' do
    let(:base64_string) { 'eyJ2YWx1ZSI6bnVsbCwiZmllbGRfdHlwZSI6IlN0cmluZyIsImZpZWxkX25hbWUiOiJhX3N0cmluZyIsImRpcmVjdGlvbiI6MSwiaW5jbHVkZV9jdXJyZW50IjpmYWxzZSwidGllYnJlYWtfaWQiOm51bGx9' }
    subject do
      described_class.new(base64_string)
    end
    its(:tiebreak_id) { should be_nil }
    its(:value) { should be_nil }
    its(:criteria) { should eq({}) }
    its(:to_s) { should eq(base64_string) }
  end

  context 'a string field cursor' do
    let(:base64_string) { 'eyJ2YWx1ZSI6ImFzdHJpbmciLCJmaWVsZF90eXBlIjoiU3RyaW5nIiwiZmllbGRfbmFtZSI6ImFfc3RyaW5nIiwiZGlyZWN0aW9uIjoxLCJpbmNsdWRlX2N1cnJlbnQiOmZhbHNlLCJ0aWVicmVha19pZCI6IjY0MDIwY2MwODliMjU0NGUyM2E3ZDZkYyJ9' }
    let(:feed_item) { Feed::Item.create!(a_string: 'astring') }
    let(:feed_id) { BSON::ObjectId.from_string('64020cc089b2544e23a7d6dc') }
    let(:criteria) do
      {
        '$or' => [
          { 'a_string' => { '$gt' => feed_item.a_string } },
          { 'a_string' => feed_item.a_string, '_id' => { '$gt' => feed_item.id } }
        ]
      }
    end
    before(:each) do
      allow(feed_item).to receive(:id).and_return(feed_id)
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
  end

  context 'an invalid cursor' do
    it 'raises a Mongoid::Scroll::Errors::InvalidBase64CursorError with an invalid Base64 string' do
      expect { described_class.new 'invalid' }.to raise_error Mongoid::Scroll::Errors::InvalidBase64CursorError, /The cursor supplied is invalid: invalid./
    end

    it 'raises a Mongoid::Scroll::Errors::InvalidBase64CursorError with an invalid JSON string' do
      expect { described_class.new 'aW52YWxpZA==' }.to raise_error Mongoid::Scroll::Errors::InvalidBase64CursorError, /The cursor supplied is invalid: aW52YWxpZA==./
    end
  end
end
