# frozen_string_literal: true

require 'rails_helper'
helper = DbSchemaHelper.new

# a simple schema that could be returned
# from DbAdapater.schema
simple_db = [                       # folder1
  helper.entry('/folder1/file1_1'), #  `- file1_1
  helper.entry('/folder1/file1_2'), #   - file1_2
  helper.entry('/folder2/file2_1'), # folder2
  helper.entry('/folder2/file2_2'), #  '- file2_1
]                                   #  `- file2_2

describe DbBuilder do
  describe '*update_db*' do
    before(:all) do
      @db = Db.new
      @db_builder = DbBuilder.new(db: @db)
    end
    describe 'given the simple_db schema' do
      before(:all) do
        @db_builder.update_db(schema: simple_db)
        @root = @db.root_folder
      end
      it 'builds a root folder' do
        expect(@root.name).to eq('root')
        expect(@root.subfolders.count).to eq(2)
        expect(@root.db_files.count).to eq(0)
      end
      it 'builds sub-folder1' do
        folder1 = @root.subfolders[0]
        expect(folder1.name).to eq('folder1')
        expect(folder1.db_files.count).to eq(2)
        expect(folder1.db_files[0].name).to eq('file1_1')
        expect(folder1.db_files[1].name).to eq('file1_2')
      end
      it 'builds sub-folder2' do
        folder2 = @root.subfolders[1]
        expect(folder2.name).to eq('folder2')
        expect(folder2.db_files.count).to eq(2)
        expect(folder2.db_files[0].name).to eq('file2_1')
        expect(folder2.db_files[1].name).to eq('file2_2')
      end
    end
    describe 'given simple_db schema with folder info streams' do
      before(:all) do
        simple_db << helper.entry('/folder1/info', metadata: { name: 'first' })
        simple_db << helper.entry('/folder2/info', metadata: { name: 'second' })
        @db_builder.update_db(schema: simple_db)
      end
      it 'uses the name info'
    end
  end
end
