# frozen_string_literal: true
require 'rails_helper'

test_nilm_url = 'http://192.168.42.17'

RSpec.describe 'CreateNilm' do
  describe 'build' do
    it 'creates and populates a Db object', :vcr do
      # mock the database updater
      service = instance_double(UpdateDb, run: '')
      allow(UpdateDb).to receive(:new).and_return(service)
      # run the NILM creation
      nilm_creator = CreateNilm.new
      nilm_creator.run(name: 'test', url: test_nilm_url)
      # verify NILM components are present
      expect(nilm_creator.nilm).to be_present
      expect(nilm_creator.nilm.db).to be_present
      # ...and the database has been populated
      expect(service).to have_received(:run)
    end
  end
end
