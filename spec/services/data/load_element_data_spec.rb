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
        {id: @elem0.id, values: 'mock0'},
        {id: @elem3.id, type: 'error', values: nil}
      ]
      expect(@mock_stream_service.run_count).to eq 2
    end
  end

  #NOTE: This is really quite a large integration test, it
  #builds the full test nilm and then retrieves data from it.
  #might be overkill but it really tests out the pipeline :)
  #
  describe 'when boundary times are not specified' do
    let (:url) {'http://localhost:8080/nilmdb'}
    let(:user) {create(:user)}

    it 'updates the streams', :vcr do
      adapter = DbAdapter.new(url)
      service = CreateNilm.new
      service.run(name: 'test', url: url, owner: user)
      db = service.nilm.db
      #request data from ac-power (15 Jun 2015 - 27 Jun 2015)
      #                  pump-events (04 Feb 2013 - 23 Feb 2013)
      elem1 = DbStream.find_by_path("/tutorial/ac-power").db_elements.first
      elem2 = DbStream.find_by_path("/tutorial/pump-events").db_elements.first
      #make sure the decimations are messed up by partial update
      ndecims1 = elem1.db_stream.db_decimations.count
      ndecims2 = elem2.db_stream.db_decimations.count
      #artificially mess up time bounds to check if service updates the streams
      elem1.db_stream.update(start_time: 0, end_time: 0)
      elem2.db_stream.update(start_time: 0, end_time: 0)
      service = LoadElementData.new
      service.run([elem1,elem2], nil, nil)
      #bounds taken from test nilm on vagrant instance
      expect(service.start_time).to eq(1360017784000000)
      expect(service.end_time).to eq(1435438182000001)
      #make sure decimations are still here
      expect(elem1.db_stream.reload.db_decimations.count).to eq ndecims1
      expect(elem2.db_stream.reload.db_decimations.count).to eq ndecims2
    end
  end
end
