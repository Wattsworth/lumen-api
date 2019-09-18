require 'rails_helper'

RSpec.describe HomeController, type: :request do
  describe 'GET index' do
      it 'returns html' do
        # no authentication required
        get "/"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Lumen")
      end
    it 'returns json' do
      get "/index.json"
      expect(response).to have_http_status(:ok)
      expect(response.header['Content-Type']).to include('application/json')
      body = JSON.parse(response.body)
      expect(body['node_name']).to eq "Test Environment"
      expect(body['send_emails']).to eq false
      expect(body.keys).to include "version"

    end
  end
end
