# frozen_string_literal: true

require 'rails_helper'

describe DbAdapter do
  # use the vagrant box loaded with example database
  let (:url) {'http://localhost:8080/nilmdb'}
  it 'retrieves basic schema', :vcr do
    adapter = DbAdapter.new(url)
    adapter.schema.each do |entry|
      expect(entry).to include(:path, :attributes)
      expect(entry[:attributes]).to(
        include(:data_type, :start_time,
                :end_time, :total_rows, :total_time)
      )
    end
  end

  it 'retrieves stream specific schema', :vcr do
    adapter = DbAdapter.new(url)
    entries = adapter.stream_info(create(:db_stream,path:"/tutorial/pump-prep"))
    expect(entries[:base_entry][:path]).to eq "/tutorial/pump-prep"
    #TODO: support decimation lookup, need HTTP API to process wild cards
    expect(entries[:decimation_entries].length).to eq 0
  end

  describe 'set_stream_metadata' do
    it 'updates config_key in metadata', :vcr do
      adapter = DbAdapter.new(url)
      stream = DbStream.new(path: '/tutorial/pump-events',
      name: 'test', description: 'new', db_elements_attributes: [
        {column: 0, name: 'element1'},{column: 1, name: 'element2'}])
      result = adapter.set_stream_metadata(stream)
      expect(result[:error]).to be false
    end
    it 'returns error on server failure', :vcr do
      adapter = DbAdapter.new(url)
      stream = DbStream.new(path: '/badpath')
      result = adapter.set_stream_metadata(stream)
      expect(result[:error]).to be true
      expect(result[:msg]).to match(/badpath/)
    end
  end

  describe 'set_folder_metadata' do
    it 'updates config_key in metadata', :vcr do
      adapter = DbAdapter.new(url)
      folder = DbFolder.new(path: '/tutorial',
      name: 'test', description: 'new')
      result = adapter.set_folder_metadata(folder)
      expect(result[:error]).to be false
    end
    it 'returns error on server failure', :vcr do
      adapter = DbAdapter.new(url)
      folder = DbFolder.new(path: '/badpath')
      result = adapter.set_folder_metadata(folder)
      expect(result[:error]).to be true
      expect(result[:msg]).to match(/badpath/)
    end
  end

  describe 'get_count' do
    it 'returns number of elements in path over interval', :vcr do
      adapter = DbAdapter.new(url)
      start_time = 1361546159000000
      end_time = 1361577615684742
      path = '/tutorial/pump-events'
      raw_count = adapter.get_count(path,start_time, end_time)
      lvl4_count = adapter.get_count(path+"~decim-4",start_time, end_time)
      expect(raw_count>0).to be true
      expect(raw_count/4).to eq(lvl4_count)
    end
    it 'returns nil on server failure', :vcr do
      adapter = DbAdapter.new(url)
      start_time = 1361546159000000
      end_time = 1361577615684742
      path = '/path/does/not/exist'
      count = adapter.get_count(path,start_time, end_time)
      expect(count).to be nil
    end
  end

  describe 'get_data' do
    it 'returns array of data over interval', :vcr do
      adapter = DbAdapter.new(url)
      start_time = 1361546159000000
      end_time = 1361577615684742
      path = '/tutorial/pump-events'
      raw_data = adapter.get_data(path,start_time, end_time)
      lvl4_data = adapter.get_data(path+"~decim-4",start_time, end_time)
      expect(raw_data.length>0).to be true
      expect(raw_data.length/4).to eq(lvl4_data.length)
    end
    it 'adds nil to indicate interval breaks', :vcr do
      adapter = DbAdapter.new(url)
      start_time = 1361466001000000
      end_time = 1361577615684742
      path = '/tutorial/pump-events'
      data = adapter.get_data(path,start_time, end_time)
      expect(data.length>0).to be true
      num_intervals = data.select{|elem| elem==nil}.length
      expect(num_intervals).to eq 1
    end
  end

  describe 'get_intervals' do
    it 'returns array of interval line segments', :vcr do
      adapter = DbAdapter.new(url)
      start_time = 1360017784000000
      end_time = 1361579612066315
      path = '/tutorial/pump-events'
      intervals = adapter.get_intervals(path,start_time, end_time)
      expect(intervals.length).to eq(60) #20 intervals
    end
  end

end
