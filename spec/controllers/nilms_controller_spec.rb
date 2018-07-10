# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NilmsController, type: :request do
  let(:john) { create(:user, first_name: 'John') }
  let(:nicky) {create(:user, first_name: 'Nicky')}
  let(:steve) { create(:user, first_name: 'Steve') }
  let(:john_nilm) { create(:nilm, name: "John's NILM", admins: [john], owners: [nicky]) }
  let(:lab_nilm) { create(:nilm, name: 'Lab NILM', owners: [john]) }
  let(:pete_nilm) { create(:nilm, name: "Pete's NILM", viewers: [john])}
  let(:hidden_nilm) { create(:nilm, name: "Private NILM", owners: [steve])}

  describe 'GET index' do
    context 'with authenticated user' do
      it 'returns authorized nilms' do
        # force lazy evaluation of let to build NILMs
        john_nilm; pete_nilm; lab_nilm; hidden_nilm
        @auth_headers = john.create_new_auth_token
        get "/nilms.json", headers: @auth_headers
        expect(response.header['Content-Type']).to include('application/json')
        body = JSON.parse(response.body)
        expect(body.length).to eq 3
        body.each do |nilm|
          if(nilm['id']==john_nilm.id)
            expect(nilm["role"]).to eq("admin")
          elsif(nilm['id']==lab_nilm.id)
            expect(nilm["role"]).to eq("owner")
          elsif(nilm['id']==pete_nilm.id)
            expect(nilm["role"]).to eq("viewer")
          else
            fail "unexpected nilm in json response"
          end
        end
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        get "/nilms.json"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT update' do
    context 'with owner permissions' do
      it 'updates parameters' do
        @auth_headers = john.create_new_auth_token
        [john_nilm, lab_nilm].each do |nilm|
          put "/nilms/#{nilm.id}.json",
              params: {id: nilm.id, name: "changed:#{nilm.id}"},
              headers: @auth_headers
              expect(response).to have_http_status(:ok)
          expect(response).to have_notice_message
          expect(nilm.reload.name).to eq("changed:#{nilm.id}")
        end
      end
      it 'returns 422 on invalid nilm parameters' do
        @auth_headers = john.create_new_auth_token
        put "/nilms/#{john_nilm.id}.json",
            params: {id: john_nilm.id, name: ""},
            headers: @auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to have_error_message(/Name/)
        expect(john_nilm.reload.name).to eq("John's NILM")
      end
      it 'returns 422 on invalid db parameters' do
        # max points must be a positive number
        put "/nilms/#{john_nilm.id}.json",
            params: {max_points_per_plot: 'invalid'},
            headers: john.create_new_auth_token
        expect(response.status).to eq(422)
        expect(response).to have_error_message(/not a number/)
      end

      it 'only allows configurable db parameters to be changed' do
        # should ignore url and accept max_points
        size_db = john_nilm.db.size_db
        num_points = john_nilm.db.max_points_per_plot
        put "/nilms/#{john_nilm.id}.json",
            params: {max_points_per_plot: num_points+10, size: 'different'},
            headers:  john.create_new_auth_token
        expect(response.status).to eq(200)
        expect(response).to have_notice_message()
        expect(john_nilm.db.reload.size_db).to eq(size_db)
        expect(john_nilm.db.max_points_per_plot).to eq(num_points+10)
      end
    end
    context 'without admin permissions' do
      it 'returns unauthorized' do
        @auth_headers = john.create_new_auth_token
        num_points = pete_nilm.db.max_points_per_plot
        put "/nilms/#{pete_nilm.id}.json",
            params: {id: pete_nilm.id, name: "test"},
            headers: @auth_headers
        expect(response).to have_http_status(:unauthorized)
        expect(pete_nilm.reload.name).to eq("Pete's NILM")
        expect(pete_nilm.db.max_points_per_plot).to eq(num_points)
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        num_points = pete_nilm.db.max_points_per_plot
        put "/nilms/#{pete_nilm.id}.json",
            params: {id: pete_nilm.id, name: "test"}
        expect(response).to have_http_status(:unauthorized)
        expect(pete_nilm.reload.name).to eq("Pete's NILM")
        expect(pete_nilm.db.max_points_per_plot).to eq(num_points)
      end
    end
  end

  describe 'GET show' do
    context 'with any permissions' do

      it 'returns nilm and nested root folder as json' do
        # john has some permission on all 3 nilms
        [pete_nilm, lab_nilm, john_nilm].each do |nilm|
          get "/nilms/#{nilm.id}.json",
              headers: john.create_new_auth_token
          expect(response.status).to eq(200)
          expect(response.header['Content-Type']).to include('application/json')
          body = JSON.parse(response.body)
          expect(body['data']['name']).to eq(nilm.name)
          expect(body['data']['root_folder']['name']).to_not be_empty
        end
      end
      it 'returns joule modules as json' do
        test_module = create(:joule_module, name: 'test', description: 'sample')
        john_nilm.joule_modules << test_module
        get "/nilms/#{john_nilm.id}.json",
            headers: john.create_new_auth_token
        body = JSON.parse(response.body)
        expect(body['data']['jouleModules'][0]['name']).to eq(test_module.name)
        expect(body['data']['jouleModules'][0]['url']).to start_with("http://#{test_module.joule_id}.interfaces")
      end
      it 'refreshes nilm data when requested' do
        @auth_headers = john.create_new_auth_token
        [john_nilm, lab_nilm].each do |nilm|
          mock_adapter = instance_double(Nilmdb::Adapter)
          mock_service = UpdateNilm.new(mock_adapter)
          expect(mock_service).to receive(:run).and_return StubService.new
          allow(UpdateNilm).to receive(:new)
                           .and_return(mock_service)
          get "/nilms/#{nilm.id}.json?refresh=1",
              headers: @auth_headers
          expect(response).to have_http_status(:ok)
          expect(response.header['Content-Type']).to include('application/json')
        end
      end
    end
    context 'with anyone else' do
      it 'returns unauthorized' do
        @auth_headers = steve.create_new_auth_token
        get "/nilms/#{john_nilm.id}.json",
          headers: @auth_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        put "/nilms/#{pete_nilm.id}.json?refresh=1"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST create' do
    context 'with authenticated user' do
      it 'creates a NILM' do
        result = StubService.new
        result.add_error("cannot contact database")
        @mock_adapter = instance_double(Nilmdb::Adapter,
                                        node_type: 'nilmdb',
                                        refresh: result)
        allow(NodeAdapterFactory).to receive(:from_url).and_return(@mock_adapter)

        @auth_headers = john.create_new_auth_token
        post "/nilms.json",
          params: {name: 'new', url: 'http://sampleurl/nilmdb'},
          headers: @auth_headers
        expect(response).to have_http_status(:ok)
        #should have a warning that NILM cannot see database
        expect(response).to have_warning_message
        # make sure the NILM was built
        nilm = Nilm.find_by_name('new')
        expect(nilm).to_not be nil
        expect(@mock_adapter).to have_received(:refresh)
        # user should be an admin
        expect(john.admins_nilm?(nilm)).to be true
      end

      it 'returns errors on invalid request' do
        # name must be unique
        create(:nilm, url: 'http://can/only/be/one')
        @auth_headers = john.create_new_auth_token
        post "/nilms.json",
          params: {name: 'CanOnlyBeOne', url: 'http://can/only/be/one'},
          headers: @auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to have_error_message
        # make sure the NILM was not built
        expect(Nilm.where(url: 'http://can/only/be/one').count).to eq 1
      end
    end

    context 'without sign-in' do
      it 'returns unauthorized' do
        post "/nilms.json",
            params: {name: 'new', url: 'http://sampleurl/nilmdb'}
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE destroy' do
    context 'with nilm admin' do
      it 'removes the nilm' do
        @auth_headers = john.create_new_auth_token
        delete "/nilms/#{john_nilm.id}.json",
          headers: @auth_headers
        expect(response).to have_http_status(:ok)
        expect(response).to have_notice_message
        expect(Nilm.exists?(john_nilm.id)).to be false
      end
    end
    context 'with anybody else' do
      it 'returns unauthorized' do
        @auth_headers = nicky.create_new_auth_token
        delete "/nilms/#{john_nilm.id}.json",
          headers: @auth_headers
        expect(response).to have_http_status(:unauthorized)
        expect(Nilm.exists?(john_nilm.id)).to be true
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        delete "/nilms/#{john_nilm.id}.json"
        expect(response).to have_http_status(:unauthorized)
        expect(Nilm.exists?(john_nilm.id)).to be true
      end
    end
  end
end
