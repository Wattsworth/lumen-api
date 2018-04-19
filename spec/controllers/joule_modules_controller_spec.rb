# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JouleModulesController, type: :request do
  let(:john) { create(:user, first_name: 'John') }
  let(:steve) { create(:user, first_name: 'Steve') }
  let(:john_nilm) { create(:nilm, name: "John's NILM", admins: [john]) }
  let(:lab_nilm) { create(:nilm, name: 'Lab NILM', owners: [john]) }
  let(:pete_nilm) { create(:nilm, name: "Pete's NILM", viewers: [john])}

  # index action does not exist
  describe 'GET show' do
    context 'with any permissions' do
      it 'returns the modules as json' do
        # john has some permission on all 3 nilms
        @auth_headers = john.create_new_auth_token
        [pete_nilm, lab_nilm, john_nilm].each do |nilm|
          get "/joule_modules/#{nilm.id}.json",
              headers: @auth_headers
          expect(response.status).to eq(200)
          expect(response.header['Content-Type']).to include('application/json')
        end
      end
      it 'refreshes modules when requested' do
        @mock_adapter = double(JouleAdapter)
        allow(JouleAdapter).to receive(:new).and_return(@mock_adapter)
        expect(@mock_adapter).to receive(:module_info).and_return([])
        @auth_headers = john.create_new_auth_token
        get "/joule_modules/#{john_nilm.id}.json?refresh=1",
            headers: @auth_headers
        expect(response.status).to eq(200)
        expect(response.header['Content-Type']).to include('application/json')
      end
      it 'injects the proxy URL parameter into the module json' do
        test_module = create(:joule_module, name: 'test', description: 'sample')
        john_nilm.joule_modules << test_module

        get "/joule_modules/#{john_nilm.id}.json",
            headers: john.create_new_auth_token
        body = JSON.parse(response.body)
        expect(body['data'][0]['name']).to eq(test_module.name)
        expect(body['data'][0]['url']).to start_with("http://#{test_module.id}.modules")
      end
    end
    context 'without permissions' do
      it 'returns unauthorized' do
        # steve does NOT have permissions on john_nilm
        @auth_headers = steve.create_new_auth_token
        get "/joule_modules/#{john_nilm.id}.json",
            headers: @auth_headers
        expect(response.status).to eq(401)
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        #  no headers: nobody is signed in, deny all
        get "/joule_modules/#{john_nilm.id}.json"
        expect(response.status).to eq(401)
      end
    end
  end
end
