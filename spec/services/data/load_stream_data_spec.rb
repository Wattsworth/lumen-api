# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'LoadStreamData' do
  let(:db) { create(:db, max_points_per_plot: 100) }

  describe 'with large datasets' do
    describe 'when the data is decimated' do
      before do
        #decimated data (3 elements)
        @data = [[40,0,1,2,-1,0,1,1,2,3],
                 nil,
                 [50,0,1,2,-1,0,1,1,2,3]]
        @db_stream = create(:db_stream, elements_count: 0,
                            db: db, decimations_count: 3, # lvl64
                            start_time: 0, end_time: 100)
        #create the db elements
        types = ['discrete','continuous','event']
        3.times do |i|
          @db_stream.db_elements << create(:db_element,
            column: i, offset: i+1, scale_factor:i+2, display_type: types[i])
        end

        @mockAdapter = MockDataDbAdapter.new(
          start_time: @db_stream.start_time,
          end_time: @db_stream.end_time,
          raw_count: 1600, data: @data
        )

        @service = LoadStreamData.new(@mockAdapter)
      end
      it 'sets @type to [decimated]' do
        @service.run(@db_stream, 10, 90)
        expect(@service.success?).to be true
        expect(@service.data_type).to eq('decimated')
      end
      it 'finds appropriate level based on nilm resolution' do
        # expect level 16 decimation to meet plotting requirements
        @service.run(@db_stream, 10, 90)
        expect(@mockAdapter.level_retrieved).to eq(16)
        # with higher resolution setting, level 4 should meet requirements
        db.max_points_per_plot = 425; db.save
        @service.run(@db_stream, 10, 90)
        expect(@mockAdapter.level_retrieved).to eq(4)
        # with lower resolution setting, level 64 should meet requirements
        db.max_points_per_plot = 26; db.save
        @service.run(@db_stream, 10, 90)
        expect(@mockAdapter.level_retrieved).to eq(64)
      end
      it 'populates @data structure with decimated data' do
        @service.run(@db_stream, 10, 90)
        expect(@service.data.length).to eq 3
        d_count = 0
        i_count = 0
        @service.data.each_with_index do |data,i|
          elem = @db_stream.db_elements.find_by_column(i)
          expect(data[:id]).to eq elem.id
          if(elem.display_type=="discrete" || elem.display_type=="continuous")
            d_count += 1
            mean = __scale_value(i,elem)
            min =  __scale_value(i-1,elem)
            max =  __scale_value(i+1,elem)
            expect(data[:type]).to eq 'decimated'
            expect(data[:values]).to eq([[40,mean,min,max],
                                          nil,
                                         [50,mean,min,max]])
          else
            i_count += 1
            expect(data[:type]).to eq 'interval'
            expect(data[:values]).to eq [[40,0],[50,0]]
          end
        end
        expect(d_count).to eq 2 #2 decimated Streams
        expect(i_count).to eq 1 #1 interval stream
      end
    end
    describe 'when the data is not decimated' do
      before do
        @data = [[98,0],[99,0],
                 nil,
                 [110,0],[115,0]]
        @db_stream = create(:db_stream, elements_count: 0,
                            db: db, decimations_count: 1, # lvl4
                            start_time: 0, end_time: 100)
        #create the db elements
        3.times do |i|
          @db_stream.db_elements << create(:db_element,
            column: i, offset: i+1, scale_factor:i+2)
        end
        @mockAdapter = MockDataDbAdapter.new(
          start_time: @db_stream.start_time,
          end_time: @db_stream.end_time,
          raw_count: 1000, data: @data
        )
        @service = LoadStreamData.new(@mockAdapter)
      end
      it 'sets @type to [interval] if all decimations have too much data' do
        @service.run(@db_stream, 10, 90)
        expect(@service.success?).to be true
        expect(@service.data_type).to eq('interval')
        expect(@mockAdapter.level_retrieved).to be 1
      end
      it 'sets @data to intervals' do
        @service.run(@db_stream, 10, 90)
        @service.data.each_with_index do |data,i|
          elem = @db_stream.db_elements.find_by_column(i)
          expect(data[:id]).to eq elem.id
          expect(data[:values]).to eq(@data)
        end
      end
    end
  end
  describe 'with small datasets' do
    before do
      @data = [[40,0,1,2],nil,[50,0,1,2]]
      @db_stream = create(:db_stream, elements_count: 0,
                          db: db, decimations_count: 3, # lvl64
                          start_time: 0, end_time: 100)
      #create the db elements
      3.times do |i|
        @db_stream.db_elements << create(:db_element,
          column: i, offset: i+1, scale_factor:i+2)
      end
      @mockAdapter = MockDataDbAdapter.new(
        start_time: @db_stream.start_time,
        end_time: @db_stream.end_time,
        raw_count: 100, data: @data
      )

      @service = LoadStreamData.new(@mockAdapter)
    end
    it 'sets @type to [raw]' do
      @service.run(@db_stream, 10, 90)
      expect(@service.success?).to be true
      expect(@service.data_type).to eq('raw')
      expect(@mockAdapter.level_retrieved).to eq(1)
    end
    it 'only if count <= nilm resolution over interval' do
      #must have decimated data ready!
      #use custom adapter and service objects
      data = [[40,0,1,2,3,4,5,6,7,8],nil,[50,0,1,2,3,4,5,6,7,8]]
      adapter = MockDataDbAdapter.new(
        start_time: @db_stream.start_time,
        end_time: @db_stream.end_time,
        raw_count: 100, data: data
      )
      service = LoadStreamData.new(adapter)
      db.max_points_per_plot = 90; db.save
      service.run(@db_stream, 10, 90)
      expect(adapter.level_retrieved).to be > 1
    end
    it 'populates @data structure with raw data' do
      @service.run(@db_stream, 10, 90)
      @service.data.each_with_index do |data,i|
        elem = @db_stream.db_elements.find_by_column(i)
        expect(data[:id]).to eq elem.id
        expect(data[:values]).to eq([[40,(i-elem.offset)*elem.scale_factor],
                                  nil,
                                  [50,(i-elem.offset)*elem.scale_factor]])
      end
    end
  end


  describe 'when data is not present' do
    before do
      @data = [1, 2, 3]
      @db_stream = create(:db_stream, elements_count: 0,
                          db: db, decimations_count: 4, # lvl64
                          start_time: 100, end_time: 200)
      #create the db elements
      3.times do |i|
        @db_stream.db_elements << create(:db_element,
          column: i, offset: i+1, scale_factor:i+2)
      end
      @mockAdapter = MockDataDbAdapter.new(
        start_time: @db_stream.start_time,
        end_time: @db_stream.end_time,
        raw_count: 400, data: @data
      )
      @service = LoadStreamData.new(@mockAdapter)
    end
    it 'still succeeds' do
      #requested interval is before actual data
      @service.run(@db_stream, 0, 50)
      expect(@service.success?).to be true
      expect(@service.data_type).to eq('raw')
      expect(@mockAdapter.level_retrieved).to eq 1
      #all data is after request
    end
    it 'sets data values to empty arrays' do
      @service.run(@db_stream, 0, 50)
      @service.data.each_with_index do |data,i|
        elem = @db_stream.db_elements.find_by_column(i)
        expect(data[:id]).to eq elem.id
        expect(data[:values]).to eq([])
      end
    end
  end


end

def __scale_value(value,element)
  (value.to_f-element.offset)*element.scale_factor
end
