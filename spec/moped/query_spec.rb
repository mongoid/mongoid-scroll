require 'spec_helper'

describe Moped::Query do
  context "scrollable" do
    subject do
      Feed::Item.collection.find
    end
    it ":scroll" do
      subject.should.respond_to? :scroll
    end
  end
  context "with multiple sort fields" do
    subject do
      Feed::Item.collection.find.sort(name: 1, value: -1)
    end
    it "raises Mongoid::Scroll::Errors::MultipleSortFieldsError" do
      expect { subject.scroll }.to raise_error Mongoid::Scroll::Errors::MultipleSortFieldsError,
        /You're attempting to scroll over data with a sort order that includes multiple fields: name, value./
    end
  end
  context "with no sort" do
    subject do
      Feed::Item.collection.find
    end
    it "adds a default sort by _id" do
      subject.scroll.operation.selector["$orderby"].should == { "_id" => 1 }
    end
  end
  context "with data" do
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
    context "default" do
      it "scrolls all" do
        records = []
        Feed::Item.collection.find.scroll do |record, next_cursor|
          records << record
        end
        records.size.should == 10
        records.should eq Feed::Item.collection.find.to_a
      end
    end
    { a_string: String, a_integer: Integer, a_date: Date, a_datetime: DateTime }.each_pair do |field_name, field_type|
      context field_type do
        it "scrolls all with a block" do
          records = []
          Feed::Item.collection.find.sort(field_name => 1).scroll do |record, next_cursor|
            records << record
          end
          records.size.should == 10
          records.should eq Feed::Item.collection.find.to_a
        end
        it "scrolls all with a break" do
          records = []
          cursor = nil
          Feed::Item.collection.find.sort(field_name => 1).limit(5).scroll do |record, next_cursor|
            records << record
            cursor = next_cursor
          end
          records.size.should == 5
          Feed::Item.collection.find.sort(field_name => 1).scroll(cursor) do |record, next_cursor|
            records << record
            cursor = next_cursor
          end
          records.size.should == 10
          records.should eq Feed::Item.collection.find.to_a
        end
        it "scrolls in descending order" do
          records = []
          Feed::Item.collection.find.sort(field_name => -1).limit(3).scroll(nil, { field_type: field_type }) do |record, next_cursor|
            records << record
          end
          records.size.should == 3
          records.should eq Feed::Item.collection.find.sort(field_name => -1).limit(3).to_a
        end
        it "map" do
          record = Feed::Item.desc(field_name).limit(3).scroll.map { |record, cursor| record }.last
          cursor = Mongoid::Scroll::Cursor.from_record(record, { field_type: field_type, field_name: field_name })
          cursor.should_not be_nil
          cursor.to_s.split(":").should == [
            Mongoid::Scroll::Cursor.transform_field_value(field_type, field_name, record.send(field_name)).to_s,
            record.id.to_s
          ]
        end
      end
    end
  end
  context "with overlapping data" do
    before :each do
      3.times { Feed::Item.create! a_integer: 5 }
    end
    it "scrolls" do
      records = []
      cursor = nil
      Feed::Item.collection.find.sort(a_integer: -1).limit(2).scroll do |record, next_cursor|
        records << record
        cursor = next_cursor
      end
      records.size.should == 2
      Feed::Item.collection.find.sort(a_integer: -1).scroll(cursor) do |record, next_cursor|
        records << record
      end
      records.size.should == 3
      records.should eq Feed::Item.collection.find.to_a
    end
  end
end
