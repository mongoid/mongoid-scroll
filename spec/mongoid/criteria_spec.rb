require 'spec_helper'

describe Mongoid::Criteria do
  context "scrollable" do
    subject do
      Feed::Item
    end
    it ":scroll" do
      subject.should.respond_to? :scroll
    end
  end
  context "with multiple sort fields" do
    subject do
      Feed::Item.desc(:name).asc(:value)
    end
    it "raises Mongoid::Scroll::Errors::MultipleSortFieldsError" do
      expect { subject.scroll }.to raise_error Mongoid::Scroll::Errors::MultipleSortFieldsError,
        /You're attempting to scroll over data with a sort order that includes multiple fields: name, value./
    end
  end
  context "with no sort" do
    subject do
      Feed::Item.all
    end
    it "adds a default sort by _id" do
      subject.scroll.options[:sort].should == { "_id" => 1 }
    end
  end
  context "with data" do
    before :each do
      10.times do |i|
        Feed::Item.create!(
          a_string: i.to_s,
          a_integer: i,
          a_datetime: DateTime.new(2013, i + 1, 21, 1, 42, 3)
        )
      end
    end
    context "integer" do
      it "scrolls all with a block" do
        records = []
        Feed::Item.asc(:a_integer).scroll do |record, next_cursor|
          records << record
        end
        records.size.should == 10
        records.should eq Feed::Item.all.to_a
      end
      it "scrolls all with a break" do
        records = []
        cursor = nil
        Feed::Item.asc(:a_integer).limit(5).scroll do |record, next_cursor|
          records << record
          cursor = next_cursor
        end
        records.size.should == 5
        Feed::Item.asc(:a_integer).scroll(cursor) do |record, next_cursor|
          records << record
          cursor = next_cursor
        end
        records.size.should == 10
        records.should eq Feed::Item.all.to_a
      end
      it "scrolls in descending order" do
        records = []
        Feed::Item.desc(:a_integer).limit(3).scroll do |record, next_cursor|
          records << record
        end
        records.size.should == 3
        records.should eq Feed::Item.desc(:a_integer).limit(3).to_a
      end
      it "map" do
        record = Feed::Item.desc(:a_integer).limit(3).scroll.map { |record, cursor| record }.last
        cursor = Mongoid::Scroll::Cursor.from_record(record, { field_type: Integer, field_name: "a_integer" })
        cursor.should_not be_nil
        cursor.to_s.split(":").should == [ record.a_integer.to_s, record.id.to_s ]
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
      Feed::Item.desc(:a_integer).limit(2).scroll do |record, next_cursor|
        records << record
        cursor = next_cursor
      end
      records.size.should == 2
      Feed::Item.desc(:a_integer).scroll(cursor) do |record, next_cursor|
        records << record
      end
      records.size.should == 3
      records.should eq Feed::Item.all.to_a
    end
  end
end
