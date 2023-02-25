require 'spec_helper'

describe Mongoid::Criteria do
  context 'with multiple sort fields' do
    subject do
      Feed::Item.desc(:name).asc(:value)
    end
    it ':scroll' do
      expect(subject).to respond_to(:scroll)
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
      expect(subject.scroll.options[:sort]).to eq('_id' => 1)
    end
  end
  context 'with data' do
    before :each do
      10.times do |i|
        Feed::Item.create!(
          a_string: i.to_s,
          a_integer: i,
          a_datetime: DateTime.new(2013, i + 1, 21, 1, 42, 3, 'UTC'),
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
        expect(records.size).to eq 10
        expect(records).to eq Feed::Item.all.to_a
      end
      it 'does not change original criteria' do
        criteria = Feed::Item.where(:a_time.gt => Time.new(2013, 7, 22, 1, 2, 3))
        original_criteria = criteria.dup
        criteria.limit(2).scroll
        expect(criteria).to eq original_criteria
        cursor = nil
        criteria.limit(2).scroll(cursor) do |_record, next_cursor|
          cursor = next_cursor
        end
        criteria.scroll(cursor) do |_record, next_cursor|
          cursor = next_cursor
        end
        expect(criteria).to eq original_criteria
      end
    end

    context 'with a foreign key' do
      it 'sorts by object id' do
        records = []
        Feed::Item.asc('publisher_id').scroll { |r, _| records << r }
        expect(records).not_to be_empty
      end
    end

    { a_string: String, a_integer: Integer, a_date: Date, a_datetime: DateTime }.each_pair do |field_name, field_type|
      context field_type do
        it 'scrolls all with a block' do
          records = []
          Feed::Item.asc(field_name).scroll do |record, _next_cursor|
            records << record
          end
          expect(records.size).to eq 10
          expect(records).to eq Feed::Item.all.to_a
        end
        it 'scrolls all with a break' do
          records = []
          cursor = nil
          Feed::Item.asc(field_name).limit(5).scroll do |record, next_cursor|
            records << record
            cursor = next_cursor
          end
          expect(records.size).to eq 5
          Feed::Item.asc(field_name).scroll(cursor) do |record, next_cursor|
            records << record
            cursor = next_cursor
          end
          expect(records.size).to eq 10
          expect(records).to eq Feed::Item.all.to_a
        end
        it 'scrolls from a cursor' do
          last_record = nil
          cursor = nil
          Feed::Item.asc(field_name).limit(5).scroll do |record, next_cursor|
            last_record = record
            cursor = next_cursor
          end
          sixth_item = Feed::Item.asc(field_name).to_a[5]
          from_item = Feed::Item.asc(field_name).scroll(cursor).to_a.first
          expect(from_item).to eq sixth_item
        end
        it 'includes the current record when Mongoid::Scroll::Cursor#include_current is true' do
          last_record = nil
          cursor = nil
          Feed::Item.asc(field_name).limit(5).scroll do |record, next_cursor|
            last_record = record
            cursor = next_cursor
          end
          fifth_item = last_record
          cursor.include_current = true
          from_item = Feed::Item.asc(field_name).scroll(cursor).to_a.first
          expect(from_item).to eq fifth_item
        end
        it 'scrolls in descending order' do
          records = []
          Feed::Item.desc(field_name).limit(3).scroll do |record, _next_cursor|
            records << record
          end
          expect(records.size).to eq 3
          expect(records).to eq Feed::Item.desc(field_name).limit(3).to_a
        end
        it 'map' do
          record = Feed::Item.desc(field_name).limit(3).scroll.map { |r| r }.last
          expect(record).to_not be nil
          cursor = Mongoid::Scroll::Cursor.from_record(record, field_type: field_type, field_name: field_name)
          expect(cursor).to_not be nil
          expect(cursor.to_s.split(':')).to eq [
            Mongoid::Scroll::Cursor.transform_field_value(field_type, field_name, record.send(field_name)).to_s,
            record.id.to_s
          ]
        end
      end
    end
  end
  context 'with logic in initial criteria' do
    before :each do
      3.times do |i|
        Feed::Item.create!(
          name: "Feed Item #{i}",
          a_string: i.to_s,
          a_integer: i,
          a_datetime: DateTime.new(2015, i + 1, 21, 1, 42, 3, 'UTC'),
          a_date: Date.new(2016, i + 1, 21),
          a_time: Time.new(2015, i + 1, 22, 1, 2, 3)
        )
      end
      Feed::Item.create!(
        name: 'Feed Item 3',
        a_string: '3',
        a_integer: 3,
        a_datetime: DateTime.new(2015, 3, 2, 1, 2, 3),
        a_date: Date.new(2012, 2, 3),
        a_time: Time.new(2014, 2, 2, 1, 2, 3)
      )
    end
    it 'respects original criteria with OR logic' do
      criteria = Feed::Item.where(
        '$or' => [{ :a_time.gt => Time.new(2015, 7, 22, 1, 2, 3) }, { :a_time.lte => Time.new(2015, 7, 22, 1, 2, 3), :a_date.gte => Date.new(2015, 7, 30) }]
      ).asc(:a_time)
      records = []
      cursor = nil
      criteria.limit(2).scroll do |record, next_cursor|
        records << record
        cursor = next_cursor
      end
      expect(records.size).to eq 2
      expect(records.map(&:name)).to eq ['Feed Item 0', 'Feed Item 1']
      records = []
      criteria.limit(2).scroll(cursor) do |record, next_cursor|
        records << record
        cursor = next_cursor
      end
      expect(records.size).to eq 1
      expect(records.map(&:name)).to eq ['Feed Item 2']
    end
    it 'merges cursor criteria when no sort field is given' do
      criteria = Feed::Item.where(:a_time.gt => Time.new(2013, 7, 22, 1, 2, 3))
      feed_item = Feed::Item.where(name: 'Feed Item 1').first
      cursor_input = "#{feed_item.id}:#{feed_item.id}"
      field_type = Mongoid::Compatibility::Version.mongoid3? ? Moped::BSON::ObjectId : BSON::ObjectId
      cursor_options = { field_type: field_type, field_name: '_id', direction: 1 }
      cursor = Mongoid::Scroll::Cursor.new(cursor_input, cursor_options)
      records = []
      criteria.limit(2).scroll(cursor) do |record, next_cursor|
        records << record
        cursor = next_cursor
      end
      expect(records.size).to eq 2
    end
  end
  context 'with embeddable objects' do
    before do
      @item = Feed::Item.create! a_integer: 1, name: 'item'
      @embedded_item = Feed::EmbeddedItem.create! name: 'embedded', item: @item
    end
    it 'respects embedded queries' do
      records = []
      criteria = @item.embedded_items.limit(2)
      criteria.scroll do |record, _next_cursor|
        records << record
      end
      expect(records.size).to eq 1
      expect(records.map(&:name)).to eq ['embedded']
    end
  end
  context 'with overlapping data', if: MongoDB.mmapv1? do
    before :each do
      3.times { Feed::Item.create! a_integer: 5 }
      Feed::Item.first.update_attributes!(name: Array(1000).join('a'))
    end
    it 'natural order is different from order by id' do
      # natural order isn't necessarily going to be the same as _id order
      # if a document is updated and grows in size, it may need to be relocated and
      # thus cause the natural order to change
      expect(Feed::Item.order_by('$natural' => 1).to_a).to_not eq(Feed::Item.order_by(_id: 1).to_a)
    end
    [{ a_integer: 1 }, { a_integer: -1 }].each do |sort_order|
      it "scrolls by #{sort_order}" do
        records = []
        cursor = nil
        Feed::Item.order_by(sort_order).limit(2).scroll do |record, next_cursor|
          records << record
          cursor = next_cursor
        end
        expect(records.size).to eq 2
        Feed::Item.order_by(sort_order).scroll(cursor) do |record, _next_cursor|
          records << record
        end
        expect(records.size).to eq 3
        expect(records).to eq Feed::Item.all.sort(_id: sort_order[:a_integer]).to_a
      end
    end
  end
  context 'with several records having the same value' do
    before :each do
      3.times { Feed::Item.create! a_integer: 5 }
    end
    it 'returns records from the current one when Mongoid::Scroll::Cursor#include_current is true' do
      _first_item, second_item, third_item = Feed::Item.asc(:a_integer).to_a
      cursor = Mongoid::Scroll::Cursor.from_record(second_item, field: Feed::Item.fields['a_integer'])
      cursor.include_current = true
      items = Feed::Item.asc(:a_integer).limit(2).scroll(cursor).to_a
      expect(items).to eq([second_item, third_item])
    end
  end
end
