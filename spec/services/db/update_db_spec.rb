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
    def update_with_schema(schema, db: nil)
      # stub the database adapter
      adapter = instance_double(DbAdapter)
      allow(adapter).to receive(:schema).and_return(Array.new(schema))
      # run the update
      @db = db || Db.new
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
    describe 'uses metadata' do
      it 'from folder info stream' do
        schema = Array.new(simple_db)
        schema << helper.entry('/folder1/info', metadata: { name: 'first' })
        update_with_schema(schema)
        folder1 = @root.subfolders[0]
        expect(folder1.name).to eq('first')
      end
      it 'from base file' do
        schema = Array.new(simple_db)
        schema << helper.entry('/folder1/f1_meta', metadata: { name: 'custom' })
        update_with_schema(schema)
        folder1 = @root.subfolders[0]
        expect(folder1.db_files.find_by_name('custom')).to be_present
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
        schema = [helper.entry('/fa/fb/data', metadata: { name: 'the_file' })]
        update_with_schema(schema)
        file = DbFile.find_by_name('the_file')
        expect(file.db_folder.parent.parent).to eq(@root)
      end
    end

    # updates to remote db
    describe 'given changes to remote db' do
      it 'removes missing files' do
        # create Db with a file 'temp'
        update_with_schema([helper.entry('/folder1/temp'),
                            helper.entry('/folder1/info',
                                         metadata: { name: 'f1' })
                            ])
        temp = DbFile.find_by_name('temp')
        # the file 'temp' should be here
        expect(temp).to be_present
        # update Db without 'temp'
        update_with_schema([helper.entry('/folder1/info',
                                         metadata: { name: 'f1' })
                            ], db: @db)
        # it should be gone
        expect(DbFile.find_by_name('temp')).to be nil
        # ...and the service should have a warning
        expect(@service.warnings?).to be true
      end
      it 'removes missing folders' do
        # create Db with a folder 'temp'
        update_with_schema([helper.entry('/folder1/stub'),
                            helper.entry('/folder1/temp/info',
                                         metadata: { name: 'temp' })
                            ])
        temp = DbFolder.find_by_name('temp')
        # the file 'temp' should be here
        expect(temp).to be_present
        # update Db without 'temp'
        update_with_schema([helper.entry('/folder1/stub')],
                           db: @db)
        # it should be gone
        expect(DbFolder.find_by_name('temp')).to be nil
        # ...and the service should have a warning
        expect(@service.warnings?).to be true
      end
      it 'adds new files'
      it 'adds new folders'
    end
    describe 'given changes to remote metadata' do
      it 'updates file info'
      it 'updates folder info'
      it 'adds new streams'
      it 'removes missing streams'
    end
  end
end
