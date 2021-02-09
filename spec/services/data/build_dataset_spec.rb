# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'BuildDataset' do
  let(:nilm) {create(:nilm, name: 'test')}
  let(:db) { create(:db, nilm: nilm,  max_points_per_plot: 100) }
  let(:db_stream) { create(:db_stream, db_folder: db.root_folder, db: db, elements_count: 0) }
  let(:elem0) { create(:db_element, name: 'e0_continuous', display_type: 'continuous', column: 0, units: 'c', db_stream: db_stream) }
  let(:elem1) { create(:db_element, name: 'e1_discrete',   display_type: 'discrete',   column: 1, units: 'd', db_stream: db_stream) }
  let(:elem2) { create(:db_element, name: 'e2_event',      display_type: 'event',      column: 2, units: nil, db_stream: db_stream) }

  describe 'when stream service returns raw data' do
    before do
      data = [{id: elem0.id, type: 'raw', values: [[10,0],[11,1],nil,[12,2]]},
              {id: elem1.id, type: 'raw', values: [[10,3],[11,4],nil,[12,5]]},
              {id: elem2.id, type: 'raw', values: [[10,6],[11,7],nil,[12,8]]}]
      @mock_adapter = instance_double(Nilmdb::Adapter,
                                      load_data: { data: data, decimation_factor: 1},
                                      download_instructions: "stub")
      allow(NodeAdapterFactory).to receive(:from_nilm).and_return(@mock_adapter)
      @service = BuildDataset.new(@mock_adapter)
      @service.run(db_stream,0,100)
    end
    it 'builds the dataset' do
      expect(@service.success?).to be true
      expect(@service.data).to eq([[10,0,3,6],[11,1,4,7],[12,2,5,8]])
    end
    it 'builds the legend' do
      legend = @service.legend
      expect(legend[:start_time]).to eq 0
      expect(legend[:end_time]).to eq 100
      expect(legend[:num_rows]).to eq 3
      expect(legend[:decimation_factor]).to eq 1
      expect(legend[:columns]).to eq [
        {index: 1, name: 'time', units: 'us'},
        {index: 2, name: 'e0_continuous', units: 'c'},
        {index: 3, name: 'e1_discrete', units: 'd'},
        {index: 4, name: 'e2_event', units: 'no units'}
      ]
      expect(legend[:notes]).to be_blank
    end
  end
  describe 'when stream service returns decimated data' do
    before do
      data = [{id: elem0.id, type: 'decimated', values: [[10,0,-1,1],[11,1,0,2],nil,[12,2,1,3]]},
              {id: elem1.id, type: 'decimated', values: [[10,3,2,4],[11,4,3,5],nil,[12,5,6,7]]},
              {id: elem2.id, type: 'interval', values:  [[10,0],[11,0],nil,[12,0]]}]
      @mock_adapter = instance_double(Nilmdb::Adapter,
                                      load_data: { data: data, decimation_factor: 4},
                                      download_instructions: "stub")
      allow(NodeAdapterFactory).to receive(:from_nilm).and_return(@mock_adapter)
      @service = BuildDataset.new(@mock_adapter)
      @service.run(db_stream,0,100)
    end
    it 'omits event elements' do
      expect(@service.success?).to be true
      expect(@service.data).to eq([[10,0,3],[11,1,4],[12,2,5]])
    end
    it 'adds note to legend' do
      legend = @service.legend
      expect(legend[:decimation_factor]).to eq 4
      expect(legend[:columns]).to eq [
        {index: 1, name: 'time', units: 'us'},
        {index: 2, name: 'e0_continuous', units: 'c'},
        {index: 3, name: 'e1_discrete', units: 'd'},
      ]
      expect(legend[:notes]).to_not be_blank
    end
  end
  describe 'when stream service returns interval data' do
    before do
      data = [{id: elem0.id, type: 'interval', values: [[10,0],[11,0],nil,[12,0]]},
              {id: elem1.id, type: 'interval', values: [[10,0],[11,0],nil,[12,0]]},
              {id: elem2.id, type: 'interval', values: [[10,0],[11,0],nil,[12,0]]}]
      @mock_adapter = instance_double(Nilmdb::Adapter,
                                      load_data: { data: data, decimation_factor: 1},
                                      download_instructions: "stub")
      #allow(LoadStreamData).to receive(:new).and_return(@mock_stream_service)
      @service = BuildDataset.new(@mock_adapter)
      @service.run(db_stream,0,100)
    end
    it 'returns no data' do
      expect(@service.data).to be_empty
    end
    it 'adds note to legend' do
      expect(@service.legend[:notes]).to_not be_empty
    end
  end
  describe 'when stream service returns no data' do
    before do
      data = [{id: elem0.id, type: 'raw', values: []},
              {id: elem1.id, type: 'raw', values: []},
              {id: elem2.id, type: 'raw', values: []}]
      @mock_adapter = instance_double(Nilmdb::Adapter,
                                      load_data:{data: data, decimation_factor: 1},
                                      download_instructions: "stub")
      #allow(LoadStreamData).to receive(:new).and_return(@mock_stream_service)
      @service = BuildDataset.new(@mock_adapter)
      @service.run(db_stream,0,100)
    end
    it 'returns no data' do
      expect(@service.data).to be_empty
    end
  end
  describe 'when stream service returns error' do
    before do
      @mock_adapter = instance_double(Nilmdb::Adapter, load_data: nil)
      #allow(LoadStreamData).to receive(:new).and_return(@mock_stream_service)
      @service = BuildDataset.new(@mock_adapter)
      @service.run(db_stream,0,100)
    end
    it 'returns error' do
      expect(@service.success?).to be false
      expect(@service.errors).to_not be_empty
    end
  end
end
