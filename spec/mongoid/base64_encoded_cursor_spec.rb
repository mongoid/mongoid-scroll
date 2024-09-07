require 'spec_helper'

describe Mongoid::Scroll::Base64EncodedCursor do
  context 'new' do
    context 'an empty cursor' do
      subject do
        Mongoid::Scroll::Base64EncodedCursor.new base64_string
      end

      let(:base64_string) { 'eyJ2YWx1ZSI6bnVsbCwiZmllbGRfdHlwZSI6IlN0cmluZyIsImZpZWxkX25hbWUiOiJhX3N0cmluZyIsImRpcmVjdGlvbiI6MSwiaW5jbHVkZV9jdXJyZW50IjpmYWxzZSwidGllYnJlYWtfaWQiOm51bGwsInR5cGUiOiJuZXh0In0=' }

      its(:tiebreak_id) { is_expected.to be_nil }
      its(:value) { is_expected.to be_nil }
      its(:criteria) { is_expected.to eq({}) }
      its(:type) { is_expected.to eq(:next) }
      its(:to_s) { is_expected.to eq(base64_string) }
    end

    context 'a string field cursor' do
      subject do
        Mongoid::Scroll::Base64EncodedCursor.new base64_string
      end

      let(:base64_string) { 'eyJ2YWx1ZSI6ImEgc3RyaW5nIiwiZmllbGRfdHlwZSI6IlN0cmluZyIsImZpZWxkX25hbWUiOiJhX3N0cmluZyIsImRpcmVjdGlvbiI6MSwiaW5jbHVkZV9jdXJyZW50IjpmYWxzZSwidGllYnJlYWtfaWQiOiI2NDA2M2RmODA5NDQzNDE3YzdkMmIxMDIiLCJ0eXBlIjoibmV4dCJ9' }
      let(:a_value) { 'a string' }
      let(:tiebreak_id) { BSON::ObjectId.from_string('64063df809443417c7d2b102') }
      let(:criteria) do
        {
          '$or' => [
            { 'a_string' => { '$gt' => a_value } },
            { 'a_string' => a_value, '_id' => { '$gt' => tiebreak_id } }
          ]
        }
      end

      its(:value) { is_expected.to eq a_value }
      its(:tiebreak_id) { tiebreak_id }
      its(:value) { is_expected.to eq a_value }
      its(:tiebreak_id) { is_expected.to eq tiebreak_id }
      its(:criteria) { is_expected.to eq(criteria) }
      its(:type) { is_expected.to eq(:next) }
      its(:to_s) { is_expected.to eq(base64_string) }
    end

    context 'an id field cursor' do
      subject do
        Mongoid::Scroll::Base64EncodedCursor.new base64_string
      end

      let(:base64_string) do
        'eyJ2YWx1ZSI6IjY0MDY0NTg0MDk0NDM0MjgxZmE3MWFiMiIsImZpZWxkX3R5cGUiOiJCU09OOjpPYmplY3RJZCIsImZpZWxkX25hbWUiOiJpZCIsImRpcmVjdGlvbiI6MSwiaW5jbHVkZV9jdXJyZW50IjpmYWxzZSwidGllYnJlYWtfaWQiOiI2NDA2NDU4NDA5NDQzNDI4MWZhNzFhYjIiLCJ0eXBlIjoibmV4dCJ9'
      end
      let(:a_value) { BSON::ObjectId('64064584094434281fa71ab2') }
      let(:tiebreak_id) { a_value }
      let(:criteria) do
        {
          '$or' => [
            { 'id' => { '$gt' => a_value } },
            { 'id' => a_value, '_id' => { '$gt' => tiebreak_id } }
          ]
        }
      end

      its(:value) { is_expected.to eq a_value }
      its(:tiebreak_id) { is_expected.to eq tiebreak_id }
      its(:criteria) { is_expected.to eq(criteria) }
      its(:type) { is_expected.to eq(:next) }
      its(:to_s) { is_expected.to eq(base64_string) }
    end

    context 'an integer field cursor' do
      subject do
        Mongoid::Scroll::Base64EncodedCursor.new base64_string
      end

      let(:base64_string) { 'eyJ2YWx1ZSI6MTAsImZpZWxkX3R5cGUiOiJJbnRlZ2VyIiwiZmllbGRfbmFtZSI6ImFfaW50ZWdlciIsImRpcmVjdGlvbiI6MSwiaW5jbHVkZV9jdXJyZW50IjpmYWxzZSwidGllYnJlYWtfaWQiOiI2NDA2M2RmODA5NDQzNDE3YzdkMmIxMDgiLCJ0eXBlIjoibmV4dCJ9' }
      let(:a_value) { 10 }
      let(:tiebreak_id) { BSON::ObjectId('64063df809443417c7d2b108') }
      let(:criteria) do
        {
          '$or' => [
            { 'a_integer' => { '$gt' => 10 } },
            { 'a_integer' => 10, '_id' => { '$gt' => tiebreak_id } }
          ]
        }
      end

      its(:value) { is_expected.to eq a_value }
      its(:tiebreak_id) { tiebreak_id }
      its(:value) { is_expected.to eq a_value }
      its(:tiebreak_id) { is_expected.to eq tiebreak_id }
      its(:criteria) { is_expected.to eq(criteria) }
      its(:type) { is_expected.to eq(:next) }
      its(:to_s) { is_expected.to eq(base64_string) }
    end

    context 'a date/time field cursor' do
      subject do
        Mongoid::Scroll::Base64EncodedCursor.new base64_string
      end

      let(:base64_string) { 'eyJ2YWx1ZSI6MTM4NzU5MDEyMy4wLCJmaWVsZF90eXBlIjoiRGF0ZVRpbWUiLCJmaWVsZF9uYW1lIjoiYV9kYXRldGltZSIsImRpcmVjdGlvbiI6MSwiaW5jbHVkZV9jdXJyZW50IjpmYWxzZSwidGllYnJlYWtfaWQiOiI2NDA2NDNhNzA5NDQzNDIzOWYyZGJmODYiLCJ0eXBlIjoibmV4dCJ9' }
      let(:a_value) { DateTime.new(2013, 12, 21, 1, 42, 3, 'UTC') }
      let(:tiebreak_id) { BSON::ObjectId('640643a7094434239f2dbf86') }
      let(:criteria) do
        {
          '$or' => [
            { 'a_datetime' => { '$gt' => a_value.utc } },
            { 'a_datetime' => a_value.utc, '_id' => { '$gt' => tiebreak_id } }
          ]
        }
      end

      its(:value) { is_expected.to eq a_value }
      its(:tiebreak_id) { is_expected.to eq tiebreak_id }
      its(:criteria) { is_expected.to eq(criteria) }
      its(:type) { is_expected.to eq(:next) }
      its(:to_s) { is_expected.to eq(base64_string) }
    end

    context 'a date field cursor' do
      subject do
        Mongoid::Scroll::Base64EncodedCursor.new base64_string
      end

      let(:base64_string) { 'eyJ2YWx1ZSI6MTM4NzU4NDAwMCwiZmllbGRfdHlwZSI6IkRhdGUiLCJmaWVsZF9uYW1lIjoiYV9kYXRlIiwiZGlyZWN0aW9uIjoxLCJpbmNsdWRlX2N1cnJlbnQiOmZhbHNlLCJ0aWVicmVha19pZCI6IjY0MDY0MmM5MDk0NDM0MjEyYzRkNDQyMCIsInR5cGUiOiJuZXh0In0=' }
      let(:tiebreak_id) { BSON::ObjectId('640642c9094434212c4d4420') }
      let(:a_value) { Date.new(2013, 12, 21) }
      let(:criteria) do
        {
          '$or' => [
            { 'a_date' => { '$gt' => a_value.to_datetime.utc } },
            { 'a_date' => a_value.to_datetime.utc, '_id' => { '$gt' => tiebreak_id } }
          ]
        }
      end

      its(:value) { is_expected.to eq a_value }
      its(:tiebreak_id) { is_expected.to eq tiebreak_id }
      its(:criteria) { is_expected.to eq(criteria) }
      its(:type) { is_expected.to eq(:next) }
      its(:to_s) { is_expected.to eq(base64_string) }
    end

    context 'a time field cursor' do
      subject do
        Mongoid::Scroll::Base64EncodedCursor.new base64_string
      end

      let(:base64_string) { 'eyJ2YWx1ZSI6MTM4NzYwNTcyMy4wLCJmaWVsZF90eXBlIjoiVGltZSIsImZpZWxkX25hbWUiOiJhX3RpbWUiLCJkaXJlY3Rpb24iOjEsImluY2x1ZGVfY3VycmVudCI6ZmFsc2UsInRpZWJyZWFrX2lkIjoiNjQwNjNkNGEwOTQ0MzQxNjZiZDA1M2VkIiwidHlwZSI6Im5leHQifQ==' }
      let(:item_id) { BSON::ObjectId('640636f209443407333b46d4') }
      let(:a_value) { Time.new(2013, 12, 21, 6, 2, 3, '+00:00').utc }
      let(:tiebreak_id) { BSON::ObjectId('64063d4a094434166bd053ed') }
      let(:criteria) do
        {
          '$or' => [
            { 'a_time' => { '$gt' => a_value } },
            { 'a_time' => a_value, '_id' => { '$gt' => tiebreak_id } }
          ]
        }
      end

      its(:value) { is_expected.to eq a_value }
      its(:tiebreak_id) { tiebreak_id }
      its(:tiebreak_id) { is_expected.to eq tiebreak_id }
      its(:criteria) { is_expected.to eq(criteria) }
      its(:type) { is_expected.to eq(:next) }
      its(:to_s) { is_expected.to eq(base64_string) }
    end

    context 'an invalid field cursor' do
      it 'raises ArgumentError' do
        expect do
          Mongoid::Scroll::Base64EncodedCursor.new 'invalid', {}
        end.to raise_error Mongoid::Scroll::Errors::InvalidBase64CursorError
      end
    end

    context 'an invalid cursor' do
      it 'raises a Mongoid::Scroll::Errors::InvalidBase64CursorError with an invalid Base64 string' do
        expect { Mongoid::Scroll::Base64EncodedCursor.new 'invalid' }.to raise_error Mongoid::Scroll::Errors::InvalidBase64CursorError, /The cursor supplied is invalid: invalid./
      end

      it 'raises a Mongoid::Scroll::Errors::InvalidBase64CursorError with an invalid JSON string' do
        expect { Mongoid::Scroll::Base64EncodedCursor.new 'aW52YWxpZA==' }.to raise_error Mongoid::Scroll::Errors::InvalidBase64CursorError, /The cursor supplied is invalid: aW52YWxpZA==./
      end
    end
  end

  context 'from_record' do
    context 'a string field cursor' do
      subject do
        Mongoid::Scroll::Base64EncodedCursor.from_record feed_item, field_name: field_name, field_type: field_type
      end

      let(:field_type) { String }
      let(:field_value) { 'a string' }
      let(:field_name) { 'a_string' }
      let(:feed_item) { Feed::Item.create!(field_name => field_value) }

      its(:value) { is_expected.to eq field_value }
      its(:field_name) { is_expected.to eq field_name }
      its(:field_type) { is_expected.to eq field_type.to_s }
    end

    context 'an id field cursor' do
      subject do
        Mongoid::Scroll::Base64EncodedCursor.from_record feed_item, field_name: field_name, field_type: field_type
      end

      let(:field_type) { BSON::ObjectId }
      let(:field_name) { 'id' }
      let(:feed_item) { Feed::Item.create! }

      its(:value) { is_expected.to eq feed_item._id }
      its(:field_type) { is_expected.to eq field_type.to_s }
    end

    context 'an integer field cursor' do
      subject do
        Mongoid::Scroll::Base64EncodedCursor.from_record feed_item, field_name: field_name, field_type: field_type
      end

      let(:field_type) { Integer }
      let(:field_value) { 10 }
      let(:field_name) { 'a_integer' }
      let(:feed_item) { Feed::Item.create!(field_name => field_value) }

      its(:value) { is_expected.to eq field_value }
      its(:field_type) { is_expected.to eq field_type.to_s }
    end

    context 'a date/time field cursor' do
      subject do
        Mongoid::Scroll::Base64EncodedCursor.from_record feed_item, field_name: field_name, field_type: field_type
      end

      let(:field_type) { DateTime }
      let(:field_value) { DateTime.new(2013, 12, 21, 1, 42, 3, 'UTC') }
      let(:field_name) { 'a_datetime' }
      let(:feed_item) { Feed::Item.create!(field_name => field_value) }

      its(:value) { is_expected.to eq field_value }
      its(:field_type) { is_expected.to eq field_type.to_s }
    end

    context 'a date field cursor' do
      subject do
        Mongoid::Scroll::Base64EncodedCursor.from_record feed_item, field_name: field_name, field_type: field_type
      end

      let(:field_type) { Date }
      let(:field_value) { Date.new(2013, 12, 21) }
      let(:field_name) { 'a_date' }
      let(:feed_item) { Feed::Item.create!(field_name => field_value) }

      its(:value) { is_expected.to eq field_value }
    end

    context 'a time field cursor' do
      subject do
        Mongoid::Scroll::Base64EncodedCursor.from_record feed_item, field_name: field_name, field_type: field_type
      end

      let(:field_type) { Time }
      let(:field_value) { Time.new(2013, 12, 21, 1, 2, 3) }
      let(:field_name) { 'a_time' }
      let(:feed_item) { Feed::Item.create!(field_name => field_value) }

      its(:value) { is_expected.to eq field_value }
      its(:field_type) { is_expected.to eq field_type.to_s }
    end

    context 'an array field cursor' do
      let(:feed_item) { Feed::Item.create!(a_array: %w[x y]) }

      it 'is not supported' do
        expect do
          Mongoid::Scroll::Base64EncodedCursor.from_record feed_item, field_name: 'a_array', field_type: Array
        end.to raise_error Mongoid::Scroll::Errors::UnsupportedFieldTypeError, /The type of the field 'a_array' is not supported: Array./
      end
    end

    it 'encode and decode type option' do
      feed_item = Feed::Item.create!
      cursor = Mongoid::Scroll::Base64EncodedCursor.from_record feed_item, field_name: 'id', field_type: BSON::ObjectId, type: :previous
      expect(Mongoid::Scroll::Base64EncodedCursor.new(cursor.to_s).type).to eq(:previous)
    end

    context 'a cursor with previous set to true' do
      subject do
        Mongoid::Scroll::Base64EncodedCursor.from_record feed_item, field_name: field_name, field_type: field_type, type: :previous
      end

      let(:field_type) { BSON::ObjectId }
      let(:field_name) { 'id' }
      let(:feed_item) { Feed::Item.create! }

      its(:value) { is_expected.to eq feed_item._id }
      its(:field_type) { is_expected.to eq field_type.to_s }
      its(:type) { is_expected.to eq(:previous) }
    end
  end
end
