# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'LoadStreamData' do
  let(:nilm) { create(:nilm, name: "test")}
  let(:db) { create(:db, nilm: nilm, max_points_per_plot: 100) }

  describe 'rapid decimation algorithm' do
    it 'computes decimation level' do
      @server = Nilmdb::LoadStreamData.new(nil)
      examples = [
          {count: 0, resolution: 100, level: 1},
          {count: 100, resolution: 500, level: 1},
          {count: 1000, resolution: 500, level: 4},
          {count: 10*64, resolution: 10, level: 64},
          {count: 10*64+1, resolution: 10, level: 64*4}]
      examples.each do |example|
        level = @server._compute_decimation_level(example[:count],example[:resolution])
        expect(level).to eq example[:level]
      end
    end
  end
  describe 'with large datasets' do
    describe 'when the data is decimated' do
      before do
        #decimated data (3 elements)
        @data = [[40,0,1,2,-1,0,1,1,2,3],
                 nil,
                 [50,0,1,2,-1,0,1,1,2,3]]
        @db_stream = create(:db_stream, elements_count: 0,
                            db: db, db_folder: db.root_folder,
                            decimations_count: 3, # lvl64
                            start_time: 0, end_time: 100)
        #create the db elements
        types = ['discrete','continuous','event']
        3.times do |i|
          @db_stream.db_elements << build(:db_element,
            column: i, offset: i+1, scale_factor:i+2, display_type: types[i])
        end

        @mockAdapter = MockDataDbAdapter.new(
          start_time: @db_stream.start_time,
          end_time: @db_stream.end_time,
          raw_count: 1600, data: @data
        )

        @service = Nilmdb::LoadStreamData.new(@mockAdapter)
      end
      it 'sets @type to [decimated]' do
        @service.run(@db_stream, 10, 90)
        expect(@service.success?).to be true
        expect(@service.data_type).to eq('decimated')
      end
      it 'finds max allowed resolution by default' do
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
      it 'finds lower resolution if requested' do
        # expect level 64 decimation to meet plotting requirements
        @service.run(@db_stream, 10, 90, [], 50)
        expect(@mockAdapter.level_retrieved).to eq(64)
        # with higher resolution setting, level should stay the same
        db.max_points_per_plot = 425; db.save
        @service.run(@db_stream, 10, 90, [], 50)
        expect(@mockAdapter.level_retrieved).to eq(64)
        # when resolution > allowed, returns allowed
        db.max_points_per_plot = 26; db.save
        @service.run(@db_stream, 10, 90, [], 1000)
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
          if elem.display_type=="discrete" || elem.display_type=="continuous"
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
                            db: db, db_folder: db.root_folder,
                            decimations_count: 1, # lvl4
                            start_time: 0, end_time: 100)
        #create the db elements
        3.times do |i|
          @db_stream.db_elements << build(:db_element,
            column: i, offset: i+1, scale_factor:i+2)
        end
        @mockAdapter = MockDataDbAdapter.new(
            decimations=[1],
          start_time: @db_stream.start_time,
          end_time: @db_stream.end_time,
          raw_count: 1000, data: @data
        )
        @service = Nilmdb::LoadStreamData.new(@mockAdapter)
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
                          db: db, db_folder: db.root_folder,
                          decimations_count: 3, # lvl64
                          start_time: 0, end_time: 100)
      #create the db elements
      3.times do |i|
        @db_stream.db_elements << build(:db_element,
          column: i, offset: i+1, scale_factor:i+2)
      end
      @mockAdapter = MockDataDbAdapter.new(
        start_time: @db_stream.start_time,
        end_time: @db_stream.end_time,
        raw_count: 100, data: @data
      )

      @service = Nilmdb::LoadStreamData.new(@mockAdapter)
    end
    it 'sets @type to [raw]' do
      @service.run(@db_stream, 10, 90)
      expect(@service.success?).to be true
      expect(@service.data_type).to eq('raw')
      expect(@mockAdapter.level_retrieved).to eq(1)
    end
    it 'only if count <= nilm resolution over interval' do
      #must have decimated data ready!
      #use custom backend and service objects
      data = [[40,0,1,2,3,4,5,6,7,8],nil,[50,0,1,2,3,4,5,6,7,8]]
      backend = MockDataDbAdapter.new(
        start_time: @db_stream.start_time,
        end_time: @db_stream.end_time,
        raw_count: 100, data: data
      )
      service = Nilmdb::LoadStreamData.new(backend)
      db.max_points_per_plot = 90; db.save
      service.run(@db_stream, 10, 90)
      expect(backend.level_retrieved).to be > 1
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
      @db_stream = create(:db_stream, db_folder: db.root_folder,
                          elements_count: 0,
                          db: db, decimations_count: 4, # lvl64
                          start_time: 100, end_time: 200)
      #create the db elements
      3.times do |i|
        @db_stream.db_elements << build(:db_element,
          column: i, offset: i+1, scale_factor:i+2)
      end
      @mockAdapter = MockDataDbAdapter.new(
        start_time: @db_stream.start_time,
        end_time: @db_stream.end_time,
        raw_count: 400, data: @data
      )
      @service = Nilmdb::LoadStreamData.new(@mockAdapter)
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
