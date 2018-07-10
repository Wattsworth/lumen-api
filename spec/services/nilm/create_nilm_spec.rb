# frozen_string_literal: true
require 'rails_helper'

test_nilm_url = 'http://localhost:8080/nilmdb'

RSpec.describe 'CreateNilm' do
  describe 'build' do
    it 'creates and populates a Db object' do
      result = StubService.new
      result.add_error("unable to contact database")
      # mock the database updater
      @mock_adapter = instance_double(Nilmdb::Adapter,
                            refresh: result,
                                     node_type: 'nilmdb')
      user = create(:user, first_name: "John")
      # run the NILM creation
      nilm_creator = CreateNilm.new(@mock_adapter)
      nilm_creator.run(
        name: 'test',
        description: 'test description',
        url: test_nilm_url,
        owner: user
      )
      # verify NILM components are present
      nilm = nilm_creator.nilm
      #update errors show up as warnings
      expect(nilm_creator.warnings.length).to eq 1
      expect(nilm).to_not be nil
      expect(nilm.db).to be_present
      # ...and the database has been populated
      expect(@mock_adapter).to have_received(:refresh)
      expect(user.owns_nilm?(nilm)).to be true
    end
  end
end
