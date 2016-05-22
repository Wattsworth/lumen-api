# frozen_string_literal: true

require 'rails_helper'

helper = DbSchemaHelper.new
simple_db = [
  helper.entry('/folder1/f1_1',
               metadata: { name: 'file1_1' }, stream_count: 4),
  helper.entry('/folder1/f1_2',
               metadata: { name: 'file1_2' }, stream_count: 5),
  helper.entry('/folder2/f2_1', metadata: { name: 'file2_1' }),
  helper.entry('/folder2/f2_2', metadata: { name: 'file2_2' })
]

RSpec.describe 'parse and display a database' do
  def update_with_schema(schema)
    @db = Db.new
    @db_builder = DbBuilder.new(db: @db)
    @db_builder.update_db(schema: Array.new(schema))
    @db.save
  end

  it 'loads and displays a database' do
    # TODO
    # update_with_schema(simple_db)
    # visit db_path(@db)
  end
end
