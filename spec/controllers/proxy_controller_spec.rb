# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ProxyController, type: :request do
  let(:admin) { create(:user, first_name: 'Admin') }
  let(:owner) {create(:user, first_name: 'Owner')}
  let(:other) { create(:user, first_name: 'Other') }
  let(:test_nilm) { create(:nilm, name: "Test NILM", admins: [admin], owners: [owner]) }
  let(:test_app) { create(:data_app, name: "Test App", nilm: test_nilm)}
  let(:other_app) { create(:data_app, name: "Other App", nilm: test_nilm)}

  describe 'GET authenticate' do

    context 'with authorized user' do
      it 'creates a cookie from a token' do
        # The first request requires a token
        token = InterfaceAuthToken.create(data_app: test_app,
                                          user: owner,
                                          expiration: 5.minutes.from_now)

        get "/app/#{test_app.id}/auth",
            headers: {HTTP_X_ORIGINAL_URI: "/lumen?auth_token=#{token.value}"}
        # request is authorized
        expect(response).to have_http_status(:ok)
        # connection headers are provided
        expect(response.headers['X-PROXY-URL']).to eq test_app.url
        expect(response.headers['X-JOULE-KEY']).to eq test_nilm.key
        # cookie is set
        expect(session[:user_id]).to eq owner.id
        expect(session[:app_ids]).to include test_app.id
        # the token is destroyed
        expect(InterfaceAuthToken.find_by_id(token.id)).to be_nil

        # The next request is authorized by cookie
        get "/app/#{test_app.id}/auth",
            headers: {HTTP_X_ORIGINAL_URI: "/lumen"}
        # request is authorized
        expect(response).to have_http_status(:ok)
        # connection headers are provided
        expect(response.headers['X-PROXY-URL']).to eq test_app.url
        expect(response.headers['X-JOULE-KEY']).to eq test_nilm.key

        # If permission is revoked the cookie is invalid
        Permission.where(user: owner).destroy_all
        get "/app/#{test_app.id}/auth",
            headers: {HTTP_X_ORIGINAL_URI: "/lumen"}
        # request is unauthorized
        expect(response).to have_http_status(:unauthorized)
      end
      it 'denies expired tokens' do
        # The first request requires a token
        token = InterfaceAuthToken.create(data_app: test_app,
                                          user: owner,
                                          expiration: 5.minutes.ago)

        get "/app/#{test_app.id}/auth",
            headers: {HTTP_X_ORIGINAL_URI: "/lumen?auth_token=#{token.value}"}
        expect(response).to have_http_status(:unauthorized)
      end
      it 'requires a valid token' do
        get "/app/#{test_app.id}/auth",
            headers: {HTTP_X_ORIGINAL_URI: "/lumen?auth_token=invalid"}
        expect(response).to have_http_status(:unauthorized)
      end
      it 'requires a proxy' do
        get "/app/#{test_app.id}/auth"
        expect(response).to have_http_status(:unauthorized)
      end
      it 'requires a token or a cookie' do
        get "/app/#{test_app.id}/auth",
            headers: {HTTP_X_ORIGINAL_URI: "/lumen"}
        expect(response).to have_http_status(:unauthorized)
      end
      it 'does not allow cross app requests' do
        # validate to test_app
        token = InterfaceAuthToken.create(data_app: test_app,
                                          user: owner,
                                          expiration: 5.minutes.from_now)

        get "/app/#{test_app.id}/auth",
            headers: {HTTP_X_ORIGINAL_URI: "/lumen?auth_token=#{token.value}"}
        # request is authorized
        expect(response).to have_http_status(:ok)
        # cannot send request to other_app even though user is authorized
        get "/app/#{other_app.id}/auth",
            headers: {HTTP_X_ORIGINAL_URI: "/lumen"}
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with unauthorized user' do
      it 'blocks access even with a valid token' do
        token = InterfaceAuthToken.create(data_app: test_app,
                                          user: other,
                                          expiration: 5.minutes.from_now)
        get "/app/#{test_app.id}/auth",
            headers: {HTTP_X_ORIGINAL_URI: "/lumen?auth_token=#{token.value}"}
        # request is unauthorized
        expect(response).to have_http_status(:unauthorized)
        # the token is destroyed
        expect(InterfaceAuthToken.find_by_id(token.id)).to be_nil
      end
    end
    context 'with invalid app' do
      it 'returns not found' do
        get "/app/200003/auth",
            headers: {HTTP_X_ORIGINAL_URI: "/lumen"}
        expect(response).to have_http_status(:not_found)

      end
    end

  end
end
