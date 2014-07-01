require 'spec_helper'

describe Mongoid::Criteria do
  context 'scrollable' do
    subject do
      Feed::Item
    end
    it ':scroll' do
      subject.should.respond_to? :scroll
    end
  end
  context 'with multiple sort fields' do
    subject do
      Feed::Item.desc(:name).asc(:value)
    end
    it 'raises Mongoid::Scroll::Errors::MultipleSortFieldsError' do
      expect { subject.scroll }.to raise_error Mongoid::Scroll::Errors::MultipleSortFieldsError,
                                               /You're attempting to scroll over data with a sort order that includes multiple fields: name, value./
    end
  end
  context 'with no sort' do
    subject do
      Feed::Item.all
    end
    it 'adds a default sort by _id' do
      subject.scroll.options[:sort].should == { '_id' => 1 }
    end
  end
  context 'with data' do
    before :each do
      10.times do |i|
        Feed::Item.create!(
          a_string: i.to_s,
          a_integer: i,
          a_datetime: DateTime.new(2013, i + 1, 21, 1, 42, 3),
          a_date: Date.new(2013, i + 1, 21),
          a_time: Time.at(Time.now.to_i + i)
        )
      end
    end
    context 'default' do
      it 'scrolls all' do
        records = []
        Feed::Item.all.scroll do |record, _next_cursor|
          records << record
        end
        records.size.should == 10
        records.should eq Feed::Item.all.to_a
      end
    end
    { a_string: String, a_integer: Integer, a_date: Date, a_datetime: DateTime }.each_pair do |field_name, field_type|
      context field_type do
        it 'scrolls all with a block' do
          records = []
          Feed::Item.asc(field_name).scroll do |record, _next_cursor|
            records << record
          end
          records.size.should == 10
          records.should eq Feed::Item.all.to_a
        end
        it 'scrolls all with a break' do
          records = []
          cursor = nil
          Feed::Item.asc(field_name).limit(5).scroll do |record, next_cursor|
            records << record
            cursor = next_cursor
          end
          records.size.should == 5
          Feed::Item.asc(field_name).scroll(cursor) do |record, next_cursor|
            records << record
            cursor = next_cursor
          end
          records.size.should == 10
          records.should eq Feed::Item.all.to_a
        end
        it 'scrolls in descending order' do
          records = []
          Feed::Item.desc(field_name).limit(3).scroll do |record, _next_cursor|
            records << record
          end
          records.size.should == 3
          records.should eq Feed::Item.desc(field_name).limit(3).to_a
        end
        it 'map' do
          record = Feed::Item.desc(field_name).limit(3).scroll.map { |r, _| r }.last
          cursor = Mongoid::Scroll::Cursor.from_record(record,  field_type: field_type, field_name: field_name)
          cursor.should_not be_nil
          cursor.to_s.split(':').should == [
            Mongoid::Scroll::Cursor.transform_field_value(field_type, field_name, record.send(field_name)).to_s,
            record.id.to_s
          ]
        end
      end
    end
  end
  context 'with overlapping data' do
    before :each do
      3.times { Feed::Item.create! a_integer: 5 }
      Feed::Item.first.update_attributes!(name: Array(1000).join('a'))
    end
    it 'natural order is different from order by id' do
      # natural order isn't necessarily going to be the same as _id order
      # if a document is updated and grows in size, it may need to be relocated and
      # thus cause the natural order to change
      Feed::Item.order_by('$natural' => 1).to_a.should_not eq Feed::Item.order_by(_id: 1).to_a
    end
    [{ a_integer: 1 }, { a_integer: -1 }].each do |sort_order|
      it "scrolls by #{sort_order}" do
        records = []
        cursor = nil
        Feed::Item.order_by(sort_order).limit(2).scroll do |record, next_cursor|
          records << record
          cursor = next_cursor
        end
        records.size.should == 2
        Feed::Item.order_by(sort_order).scroll(cursor) do |record, _next_cursor|
          records << record
        end
        records.size.should == 3
        records.should eq Feed::Item.all.sort(_id: sort_order[:a_integer]).to_a
      end
    end
  end
end
