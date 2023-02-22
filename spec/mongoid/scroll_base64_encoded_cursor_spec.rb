require 'spec_helper'

describe Mongoid::Scroll::Base64EncodedCursor do
  context 'an empty cursor' do
    subject do
      Mongoid::Scroll::Base64EncodedCursor.new nil, field_name: 'a_string', field_type: String
    end
    its(:tiebreak_id) { should be_nil }
    its(:value) { should be_nil }
    its(:criteria) { should eq({}) }
    describe 'base64' do
      let(:base64_string) { 'eyJ2YWx1ZSI6bnVsbCwiZmllbGRfdHlwZSI6IlN0cmluZyIsImZpZWxkX25hbWUiOiJhX3N0cmluZyIsImRpcmVjdGlvbiI6MX0=' }
      its(:to_s) { should eq(base64_string) }
      it 'is properly decoded' do
        cursor = Mongoid::Scroll::Base64EncodedCursor.deserialize(base64_string)
        expect(cursor.tiebreak_id).to be_nil
        expect(cursor.value).to be_nil
        expect(cursor.criteria).to eq({})
      end
    end
  end
end
