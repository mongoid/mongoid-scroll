require 'spec_helper'

describe Mongoid::Scroll::BaseCursor do
  it 'requires subclasses to implement serialization' do
    expect { described_class.new(nil).to_s }.to raise_error(NotImplementedError, /to_s/)
  end

  it 'requires subclasses to implement parsing' do
    expect { described_class.new(nil).send(:parse, 'cursor') }.to raise_error(NotImplementedError, /parse/)
  end

  it 'round trips a floating-point cursor' do
    id = BSON::ObjectId.new
    cursor = Mongoid::Scroll::Cursor.from_record({ 'score' => 1.25, '_id' => id }, field_name: 'score', field_type: Float)

    expect(cursor.to_s).to eq("1.25:#{id}")
    expect(Mongoid::Scroll::Cursor.new(cursor.to_s, field_name: 'score', field_type: Float).value).to eq(1.25)
  end

  it 'rejects an unsupported field type during serialization' do
    cursor = Mongoid::Scroll::Cursor.new(nil, field_name: 'values', field_type: Array)
    cursor.value = [1]
    cursor.tiebreak_id = BSON::ObjectId.new

    expect { cursor.to_s }.to raise_error(Mongoid::Scroll::Errors::UnsupportedFieldTypeError, /Array/)
  end

  it 'includes the descending tiebreaker record when requested' do
    id = BSON::ObjectId.new
    cursor = described_class.new(3, field_name: 'score', field_type: Integer, direction: -1, include_current: true, tiebreak_id: id)

    expected = [
      { 'score' => { '$lt' => 3 } },
      { 'score' => 3, '_id' => { '$lte' => id } }
    ]
    expect(cursor.criteria).to eq('$or' => expected)
  end
end
