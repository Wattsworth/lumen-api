# frozen_string_literal: true

require 'rails_helper'
helper = DbSchemaHelper.new

# a simple schema that could be returned
# from DbAdapater.schema
# folder1
#  `- file1_1: 4 streams
#   - file1_2: 5 streams
# folder2
#  '- file2_1: 1 stream
#  `- file2_2: 3 streams

simple_db = [
  helper.entry('/folder1/f1_1',
               metadata: { name: 'file1_1' }, stream_count: 4),
  helper.entry('/folder1/f1_2',
               metadata: { name: 'file1_2' }, stream_count: 5),
  helper.entry('/folder2/f2_1',
               metadata: { name: 'file2_1' }, stream_count: 1),
  helper.entry('/folder2/f2_2',
               metadata: { name: 'file2_2' }, stream_count: 3)
]

describe 'UpdateDb' do
  describe '*run*' do
    def update_with_schema(schema)
      # stub the database adapter
      adapter = instance_double(DbAdapter)
      allow(adapter).to receive(:schema).and_return(Array.new(schema))
      # run the update
      @db = Db.new
      @service = UpdateDb.new(db: @db)
      @service.run(db_adapter: adapter)
      @root = @db.root_folder
    end
    # simple schema parsing
    describe 'given the simple_db schema' do
      it 'builds a root folder' do
        update_with_schema(simple_db)
        expect(@root.name).to eq('root')
        expect(@root.subfolders.count).to eq(2)
        expect(@root.db_files.count).to eq(0)
      end
      it 'builds sub-folder1' do
        update_with_schema(simple_db)
        folder1 = @root.subfolders[0]
        expect(folder1.name).to eq('folder1')
        expect(folder1.db_files[0].name).to eq('file1_1')
        expect(folder1.db_files[1].name).to eq('file1_2')
      end
      it 'builds files in sub-folder1' do
        update_with_schema(simple_db)
        folder1 = @root.subfolders[0]
        expect(folder1.db_files.count).to eq(2)
        file1 = folder1.db_files[0]
        file2 = folder1.db_files[1]
        expect(file1.db_streams.count).to eq(4)
        expect(file2.db_streams.count).to eq(5)
      end
      it 'builds sub-folder2' do
        update_with_schema(simple_db)
        folder2 = @root.subfolders[1]
        expect(folder2.name).to eq('folder2')
        expect(folder2.db_files.count).to eq(2)
        expect(folder2.db_files[0].name).to eq('file2_1')
        expect(folder2.db_files[1].name).to eq('file2_2')
      end
    end

    # decimation handling
    describe 'given decimations' do
      it 'adds decimations to files' do
        schema = Array.new(simple_db)
        schema << helper.entry('/folder1/f1_1~decim-4')
        schema << helper.entry('/folder1/f1_1~decim-16')
        update_with_schema(schema)
        folder1 = @root.subfolders[0]
        file1 = folder1.db_files[0]
        expect(file1.db_decimations.count).to eq(2)
      end
      it 'ignores orphaned decimations' do
        schema = Array.new(simple_db)
        # no /folder1/f1_3 so this is an orphan decimation
        schema << helper.entry('/folder1/f1_3~decim-4')
        update_with_schema(schema)
        folder1 = @root.subfolders[0]
        # expect just 2 files in this folder
        expect(folder1.db_files.count).to eq(2)
        # and a warning about orphaned decimations
        expect(@service.warnings.count).to eq(1)
      end
    end

    # info streams and metadata
    describe 'given info streams' do
      it 'uses info stream to set folder data' do
        schema = Array.new(simple_db)
        schema << helper.entry('/folder1/info', metadata: { name: 'first' })
        update_with_schema(schema)
        folder1 = @root.subfolders[0]
        expect(folder1.name).to eq('first')
      end
      it 'reads metadata from base file'
      it 'reads metadata from decimations'
    end
  end
end
