# frozen_string_literal: true
require 'rails_helper'

test_nilm_url = 'http://nilm.secondary'

RSpec.describe 'CreateNilm' do
  describe 'build' do
    it 'creates and populates a Db object' do
      # mock the database builder
      builder = instance_double(DbBuilder, update_db: '')
      allow(DbBuilder).to receive(:new).and_return(builder)
      adapter = instance_double(DbAdapter, schema: '')
      allow(DbAdapter).to receive(:new).and_return(adapter)
      # run the NILM creation
      nilm_creator = CreateNilm.new
      nilm_creator.build(name: 'test', url: test_nilm_url)
      # verify NILM components are present
      expect(nilm_creator.nilm).to be_present
      expect(nilm_creator.nilm.db).to be_present
      # ...and the database has been populated
      expect(builder).to have_received(:update_db)
    end
  end
end
