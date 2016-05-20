# frozen_string_literal: true

require 'rails_helper'

# schema data
def entry(path, type = 'uint8_1')
  { path: path, type: type,
    start_time: 0, end_time: 0,
    total_rows: 0, total_time: 0
  }
end

simple_db = [
  entry('/folder1/info'),
  entry('/folder1/file1'),
  entry('/folder1/file2'),
  entry('/empty_folder/info')
]

describe DbBuilder do

  describe 'update_db' do
    let(:db) { Db.new }
    it 'initializes an empty database' do
      db_service = instance_double('DbService', schema: simple_db)
      db_builder = DbBuilder.new(db: db, db_service: db_service)
      db_builder.update_db
      expect(db.root_folder.name).to eq('root')
    end
  end
  
end
