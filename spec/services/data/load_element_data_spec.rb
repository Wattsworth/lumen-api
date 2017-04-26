# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'LoadElementData' do
  let(:db) { create(:db, max_points_per_plot: 100) }

  describe 'when elements are from the same stream' do
    before do
      db  = create(:db, url: 'http://test/nilmdb')
      @db_stream = create(:db_stream, db: db, elements_count: 0)
      @elem0 = create(:db_element, column: 0, db_stream: @db_stream)
      @elem1 = create(:db_element, column: 1, db_stream: @db_stream)
      @elem2 = create(:db_element, column: 2, db_stream: @db_stream)
      @stream_data = [{id: @elem0.id, values: 'mock0'},
                      {id: @elem1.id, values: 'mock1'},
                      {id: @elem2.id, values: 'mock2'}]
      @mock_stream_service = MockLoadStreamData.new(
        [stream: @db_stream, data: @stream_data])
      allow(LoadStreamData).to receive(:new).and_return(@mock_stream_service)
    end
    it 'makes one request for the stream data' do
      expect(@mock_stream_service).to receive(:data).and_return(@stream_data)
      service = LoadElementData.new
      service.run([@elem0,@elem2],0,100)
      expect(service.success?).to be true
      expect(service.data).to eq [
        {id: @elem0.id, values: 'mock0'},
        {id: @elem2.id, values: 'mock2'}
      ]
    end
  end

  describe 'when elements are from different streams' do
    before do
      db  = create(:db, url: 'http://test/nilmdb')
      @db_stream1 = create(:db_stream, db: db, elements_count: 0)
      @elem0 = create(:db_element, column: 0, db_stream: @db_stream1)
      @elem1 = create(:db_element, column: 1, db_stream: @db_stream1)
      @stream1_data = [{id: @elem0.id, values: 'mock0'},
                       {id: @elem1.id, values: 'mock1'}]
      @db_stream2 = create(:db_stream, db: db, elements_count: 0)
      @elem2 = create(:db_element, column: 2, db_stream: @db_stream2)
      @elem3 = create(:db_element, column: 3, db_stream: @db_stream2)
      @stream2_data = [{id: @elem2.id, values: 'mock2'},
                       {id: @elem3.id, values: 'mock3'}]
      @mock_stream_service = MockLoadStreamData.new(
        [{stream: @db_stream1, data: @stream1_data},
         {stream: @db_stream2, data: @stream2_data}])
      allow(LoadStreamData).to receive(:new).and_return(@mock_stream_service)

    end
    it 'makes one request per stream' do
      service = LoadElementData.new
      service.run([@elem0, @elem3],0,100)
      expect(service.success?).to be true
      expect(service.data).to eq [
        {id: @elem0.id, values: 'mock0'},
        {id: @elem3.id, values: 'mock3'}
      ]
      expect(@mock_stream_service.run_count).to eq 2
    end
  end

  describe 'when a nilm does not respond' do
    before do
      db  = create(:db, url: 'http://test/nilmdb')
      @db_stream1 = create(:db_stream, db: db, db_folder: db.root_folder,
        elements_count: 0)
      @elem0 = create(:db_element, column: 0, db_stream: @db_stream1)
      @elem1 = create(:db_element, column: 1, db_stream: @db_stream1)
      @stream1_data = [{id: @elem0.id, values: 'mock0'},
                       {id: @elem1.id, values: 'mock1'}]
      @db_stream2 = create(:db_stream, db: db, db_folder: db.root_folder,
        elements_count: 0)
      @elem2 = create(:db_element, column: 2, db_stream: @db_stream2)
      @elem3 = create(:db_element, column: 3, db_stream: @db_stream2)
      @stream2_data = [{id: @elem2.id, values: 'mock2'},
                       {id: @elem3.id, values: 'mock3'}]
      @mock_stream_service = MockLoadStreamData.new(
        [{stream: @db_stream1, data: @stream1_data},
         {stream: @db_stream2, data: nil}])
      allow(LoadStreamData).to receive(:new).and_return(@mock_stream_service)
    end
    it 'fills in the data that is available' do
      service = LoadElementData.new
      service.run([@elem0, @elem3],0,100)
      expect(service.warnings.length).to eq 1
      expect(service.data).to eq [
        {id: @elem0.id, values: 'mock0'}
      ]
      expect(@mock_stream_service.run_count).to eq 2
    end
  end
end
