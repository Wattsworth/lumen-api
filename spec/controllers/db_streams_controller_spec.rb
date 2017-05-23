# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DbStreamsController, type: :request do
  let(:john) { create(:user, first_name: 'John') }
  let(:steve) { create(:user, first_name: 'Steve') }
  let(:john_nilm) { create(:nilm, name: "John's NILM", admins: [john]) }
  let(:lab_nilm) { create(:nilm, name: 'Lab NILM', owners: [john]) }
  before do
    @stream = create(:db_stream, name: 'John Stream',
                                 db_folder: john_nilm.db.root_folder,
                                 db: john_nilm.db)
  end

  # index action does not exist
  # show action does not exist

  describe 'PUT update' do
    before do
      @mock_adapter = double(DbAdapter) # MockDbAdapter.new #instance_double(DbAdapter)
      @db_success = { error: false, msg: 'success' }
      @db_failure = { error: true, msg: 'dberror' }
      allow(DbAdapter).to receive(:new).and_return(@mock_adapter)
    end

    context 'with owner permissions' do
      it 'updates nilmdb and local database' do
        @auth_headers = john.create_new_auth_token
        expect(@mock_adapter).to receive(:set_stream_metadata)
          .and_return(@db_success)
        elem = @stream.db_elements.first
        put "/db_streams/#{@stream.id}.json",
            params: { name: 'new name',
                      db_elements_attributes:
                        [{ id: elem.id, name: 'changed' }] },
            headers: @auth_headers
        expect(response.status).to eq(200)
        expect(@stream.reload.name).to eq('new name')
        expect(elem.reload.name).to eq('changed')
        expect(response).to have_notice_message
        # check to make sure JSON renders the elements
        body = JSON.parse(response.body)
        expect(body['data']['elements'].count)
          .to eq(@stream.db_elements.count)
      end

      it 'does not update if nilmdb update fails' do
        @auth_headers = john.create_new_auth_token
        expect(@mock_adapter).to receive(:set_stream_metadata)
          .and_return(@db_failure)
        name = @stream.name
        put "/db_streams/#{@stream.id}.json",
            params: { name: 'new name' },
            headers: @auth_headers
        expect(response.status).to eq(422)
        expect(@stream.reload.name).to eq(name)
        expect(response).to have_error_message(/dberror/)
      end

      it 'returns 422 on invalid stream parameters' do
        # name cannot be blank
        expect(@mock_adapter).to_not receive(:set_stream_metadata)
        @auth_headers = john.create_new_auth_token
        put "/db_streams/#{@stream.id}.json",
            params: { name: '' },
            headers: @auth_headers
        expect(response.status).to eq(422)
        expect(response).to have_error_message(/blank/)
      end

      it 'returns 422 on invalid element parameters' do
        # elements cannot have the same name
        expect(@mock_adapter).to_not receive(:set_stream_metadata)
        @auth_headers = john.create_new_auth_token
        elem1 = @stream.db_elements.first
        elemN = @stream.db_elements.last
        put "/db_streams/#{@stream.id}.json",
            params: { db_elements_attributes:
                        [{ id: elem1.id, name: elemN.name }] },
            headers: @auth_headers
        expect(response.status).to eq(422)
        expect(response).to have_error_message(/name/)
      end

      it 'only allows configurable parameters to be changed' do
        # should ignore start_time and accept name
        expect(@mock_adapter).to receive(:set_stream_metadata)
          .and_return(@db_success)
        @auth_headers = john.create_new_auth_token
        start_time = @stream.start_time
        put "/db_streams/#{@stream.id}.json",
            params: { start_time: start_time + 10, name: 'changed' },
            headers: @auth_headers
        expect(response.status).to eq(200)
        expect(@stream.reload.start_time).to eq(start_time)
        expect(@stream.name).to eq('changed')
      end
    end

    context 'without owner permissions' do
      it 'returns unauthorized' do
        @auth_headers = steve.create_new_auth_token
        name = @stream.name
        put "/db_streams/#{@stream.id}.json",
            params: { name: 'ignored' },
            headers: @auth_headers
        expect(response).to have_http_status(:unauthorized)
        expect(@stream.reload.name).to eq(name)
      end
    end

    context 'without sign-in' do
      it 'returns unauthorized' do
        name = @stream.name
        put "/db_streams/#{@stream.id}.json",
            params: { name: 'ignored' }
        expect(response).to have_http_status(:unauthorized)
        expect(@stream.name).to eq(name)
      end
    end
  end

  describe 'POST data' do
    before do
      @mock_adapter = double(DbAdapter) # MockDbAdapter.new #instance_double(DbAdapter)
      @db_success = { error: false, msg: 'success' }
      @db_failure = { error: true, msg: 'dberror' }
      allow(DbAdapter).to receive(:new).and_return(@mock_adapter)
    end

    context 'with viewer permissions' do
      it 'returns dataset file as csv file' do
        #2 elements, two rows
        @service_data = [[1e6,1,2],[2e6,3,4]]
        @service_legend = {
          start_time: 1e6,
          end_time: 1e6,
          num_rows: 2,
          decimation_factor: 1,
          notes: 'note_test_string',
          columns: [{index: 1, name: 'time', units: 'us'},
                    {index: 2, name: 'e1', units: 'watts'},
                    {index: 3, name: 'e2', units: 'joules'}]
        }
        @mock_service = instance_double(BuildDataset,
                                        run: StubService.new,
                                        success?: true,
                                        data: @service_data,
                                        legend: @service_legend)
        allow(BuildDataset).to receive(:new).and_return(@mock_service)

        @auth_headers = john.create_new_auth_token
        post "/db_streams/#{@stream.id}/data.csv",
            params: { start_time: 0, end_time: 100},
            headers: @auth_headers
        expect(response).to have_http_status(:ok)
        text = response.body
        expect(text).to include 'note_test_string'
      end
      it 'returns error if data cannot be found' do
        @mock_service = instance_double(BuildDataset,
                                        run: StubService.new,
                                        success?: false)
        allow(BuildDataset).to receive(:new).and_return(@mock_service)

        @auth_headers = john.create_new_auth_token
        post "/db_streams/#{@stream.id}/data.csv",
            params: { start_time: 0, end_time: 100},
            headers: @auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
    context 'without viewer permissions' do
      it 'returns unauthorized' do
        @auth_headers = steve.create_new_auth_token
        post "/db_streams/#{@stream.id}/data.json",
            params: { name: 'ignored' },
            headers: @auth_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        post "/db_streams/#{@stream.id}/data.json",
            params: { start_time: 0, end_time: 100 }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
