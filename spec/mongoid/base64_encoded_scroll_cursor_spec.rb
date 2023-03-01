require 'spec_helper'

describe Mongoid::Scroll::Base64EncodedCursor do
  context 'an empty cursor' do
    let(:base64_string) { 'eyJ2YWx1ZSI6bnVsbCwiZmllbGRfdHlwZSI6IlN0cmluZyIsImZpZWxkX25hbWUiOiJhX3N0cmluZyIsImRpcmVjdGlvbiI6MX0=' }
    subject do
      described_class.new nil, field_name: 'a_string', field_type: String
    end
    its(:tiebreak_id) { should be_nil }
    its(:value) { should be_nil }
    its(:criteria) { should eq({}) }
    its(:to_s) { should eq(base64_string) }
    describe '.deserialize' do
      it 'is properly decoded' do
        cursor = described_class.deserialize(base64_string)
        expect(cursor.tiebreak_id).to be_nil
        expect(cursor.value).to be_nil
        expect(cursor.criteria).to eq({})
      end
    end
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
end
