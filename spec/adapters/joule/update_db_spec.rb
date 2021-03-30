# frozen_string_literal: true

require 'rails_helper'
require 'json'

# Test Database Schema:
# │
# ├── folder_1
# │   ├── stream_1_1: float32_3
# │   └── stream_1_2: uint8_3
# ├── folder_2
# │   └── stream_2_1: int16_2
# │   └── transients (event stream)
# │   └── loads (event stream)
# ├── folder_3
# │   ├── folder_3_1
# │   │   └── stream_3_1_1: int32_3
# │   └── stream_3_1: uint16_3
# └── folder_4
#     └── folder_4_1

describe Joule::UpdateDb do
  before do
    raw = File.read(File.dirname(__FILE__)+"/test_db_schema.json")
    @schema = JSON.parse(raw).deep_symbolize_keys
    @db = Db.new
  end

  let(:dbinfo) { {} }
  describe '*run*' do
    describe 'given the test database schema' do
      it 'builds the database' do
        service = Joule::UpdateDb.new(@db)
        service.run({}, @schema)
        expect(@db.root_folder.subfolders.count).to eq 4
        # go through Folder 1 carefully
        folder_1 = @db.root_folder.subfolders.where(name: 'folder_1').first
        expect(folder_1.subfolders.count).to eq 0
        expect(folder_1.db_streams.count).to eq 2
        expect(folder_1.path).to eq '/folder_1'
        stream_1_1 = folder_1.db_streams.where(name: 'stream_1_1').first
        expect(stream_1_1.data_type).to eq 'float32_3'
        expect(stream_1_1.path).to eq '/folder_1/stream_1_1'
        expect(stream_1_1.db_elements.count).to eq 3
        x = stream_1_1.db_elements.where(name: 'x').first
        expect(x.display_type).to eq 'continuous'
        expect(x.column).to eq 0
        expect(x.default_max).to eq 100
        y = stream_1_1.db_elements.where(name: 'y').first
        expect(y.display_type).to eq 'event'
        expect(y.column).to eq 1
        expect(y.default_min).to eq -6
        z = stream_1_1.db_elements.where(name: 'z').first
        expect(z.display_type).to eq 'discrete'
        expect(z.column).to eq 2
        expect(z.units).to eq "watts"
        # check for event streams in Folder 2
        folder_2 = @db.root_folder.subfolders.where(name: 'folder_2').first
        expect(folder_2.event_streams.count).to eq 2
        events_2_1 = folder_2.event_streams.where(name: 'events_2_1').first
        expect(events_2_1.path).to eq '/folder_2/events_2_1'
        expect(events_2_1.joule_id).to eq 100

        # quick checks
        expect(DbElement.count).to eq 14
        expect(DbStream.count).to eq 5
        expect(DbFolder.count).to eq 7
        expect(EventStream.count).to eq 2
      end
    end
  end
end