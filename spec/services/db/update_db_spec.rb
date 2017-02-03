# frozen_string_literal: true

require 'rails_helper'
helper = DbSchemaHelper.new

# a simple schema that could be returned
# from DbAdapater.schema
# folder1
#  `- stream1_1: 4 elements
#   - stream1_2: 5 elements
# folder2
#  '- stream2_1: 1 element
#  `- stream2_2: 3 elements

simple_db = [
  helper.entry('/folder1/f1_1',
               metadata: { name: 'stream1_1' }, element_count: 4),
  helper.entry('/folder1/f1_2',
               metadata: { name: 'stream1_2' }, element_count: 5),
  helper.entry('/folder2/f2_1',
               metadata: { name: 'stream2_1' }, element_count: 1),
  helper.entry('/folder2/f2_2',
               metadata: { name: 'stream2_2' }, element_count: 3)
]

describe 'UpdateDb' do
  let(:dbinfo) { {} }
  describe '*run*' do
    def update_with_schema(schema, db: nil)
      @db = db || Db.new
      @service = UpdateDb.new(db: @db)
      mock_info =
      @service.run(dbinfo, schema) #ignore dbinfo
      @root = @db.root_folder
    end
    # simple schema parsing
    describe 'given the simple_db schema' do
      it 'builds a root folder' do
        update_with_schema(simple_db)
        expect(@root.name).to eq('root')
        expect(@root.subfolders.count).to eq(2)
        expect(@root.db_streams.count).to eq(0)
      end
      it 'builds sub-folder1' do
        update_with_schema(simple_db)
        folder1 = @root.subfolders[0]
        expect(folder1.name).to eq('folder1')
        expect(folder1.db_streams[0].name).to eq('stream1_1')
        expect(folder1.db_streams[1].name).to eq('stream1_2')
      end
      it 'builds streams in sub-folder1' do
        update_with_schema(simple_db)
        folder1 = @root.subfolders[0]
        expect(folder1.db_streams.count).to eq(2)
        stream1 = folder1.db_streams[0]
        stream2 = folder1.db_streams[1]
        expect(stream1.db_elements.count).to eq(4)
        expect(stream2.db_elements.count).to eq(5)
      end
      it 'builds sub-folder2' do
        update_with_schema(simple_db)
        folder2 = @root.subfolders[1]
        expect(folder2.name).to eq('folder2')
        expect(folder2.db_streams.count).to eq(2)
        expect(folder2.db_streams[0].name).to eq('stream2_1')
        expect(folder2.db_streams[1].name).to eq('stream2_2')
      end
    end

    # decimation handling
    describe 'given decimations' do
      it 'adds decimations to streams' do
        schema = Array.new(simple_db)
        schema << helper.entry('/folder1/f1_1~decim-4')
        schema << helper.entry('/folder1/f1_1~decim-16')
        update_with_schema(schema)
        folder1 = @root.subfolders[0]
        stream1 = folder1.db_streams[0]
        expect(stream1.db_decimations.count).to eq(2)
      end
      it 'ignores orphaned decimations' do
        schema = Array.new(simple_db)
        # no /folder1/f1_3 so this is an orphan decimation
        schema << helper.entry('/folder1/f1_3~decim-4')
        update_with_schema(schema)
        folder1 = @root.subfolders[0]
        # expect just 2 streams in this folder
        expect(folder1.db_streams.count).to eq(2)
        # and a warning about orphaned decimations
        expect(@service.warnings.count).to eq(1)
      end
    end

    # info elements and metadata
    describe 'uses metadata' do
      it 'from folder info element' do
        schema = Array.new(simple_db)
        schema << helper.entry('/folder1/info', metadata: { name: 'first' })
        update_with_schema(schema)
        folder1 = @root.subfolders[0]
        expect(folder1.name).to eq('first')
      end
      it 'from base stream' do
        schema = Array.new(simple_db)
        schema << helper.entry('/folder1/f1_meta', metadata: { name: 'custom' })
        update_with_schema(schema)
        folder1 = @root.subfolders[0]
        expect(folder1.db_streams.find_by_name('custom')).to be_present
      end
    end

    # corner cases
    describe 'cornercases:' do
      it 'handles empty folders' do
        schema = [helper.entry('/folder_lonley/info',
                               metadata: { name: 'lonely' })]
        update_with_schema(schema)
        expect(@root.subfolders.find_by_name('lonely')).to be_present
      end
      it 'handles chains of folders' do
        schema = [helper.entry('/fa/fb/data', metadata: { name: 'the_stream' })]
        update_with_schema(schema)
        stream = DbStream.find_by_name('the_stream')
        expect(stream.db_folder.parent.parent).to eq(@root)
      end
    end

    # updates to remote db
    describe 'given changes to remote db' do
      it 'removes missing streams' do
        # create Db with a stream 'temp'
        update_with_schema([helper.entry('/folder1/temp'),
                            helper.entry('/folder1/info',
                                         metadata: { name: 'f1' })])
        temp = DbStream.find_by_name('temp')
        # the stream 'temp' should be here
        expect(temp).to be_present
        # update Db without 'temp'
        update_with_schema([helper.entry('/folder1/info',
                                         metadata: { name: 'f1' })],
                           db: @db)
        # it should be gone
        expect(DbStream.find_by_name('temp')).to be nil
        # ...and the service should have a warning
        expect(@service.warnings?).to be true
      end
      it 'removes missing folders' do
        # create Db with a folder 'temp'
        update_with_schema([helper.entry('/folder1/stub'),
                            helper.entry('/folder1/temp/info',
                                         metadata: { name: 'temp' })])
        temp = DbFolder.find_by_name('temp')
        # the stream 'temp' should be here
        expect(temp).to be_present
        # update Db without 'temp'
        update_with_schema([helper.entry('/folder1/stub')],
                           db: @db)
        # it should be gone
        expect(DbFolder.find_by_name('temp')).to be nil
        # ...and the service should have a warning
        expect(@service.warnings?).to be true
      end
      it 'adds new streams' do
        # create Db with 1 folder and stream
        update_with_schema([helper.entry('/folder1/old_stream')])
        @folder = @root.subfolders.first
        expect(@folder.db_streams.count).to eq(1)
        # run update again with a new stream added
        update_with_schema([helper.entry('/folder1/old_stream'),
                            helper.entry('/folder1/new_stream')],
                           db: @db)
        expect(@folder.db_streams.count).to eq(2)
      end
      it 'adds new folders' do
        # create Db with 1 folder and stream
        update_with_schema([helper.entry('/folder1/old_stream')])
        @folder = @root.subfolders.first
        expect(@folder.subfolders.count).to eq(0)
        # run update again with a new stream added
        update_with_schema([helper.entry('/folder1/old_stream'),
                            helper.entry('/folder1/new_folder/info')],
                           db: @db)
        expect(@folder.subfolders.count).to eq(1)
      end
    end
  end
end
