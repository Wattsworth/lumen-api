# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UsersController, type: :request do
  let(:steve) { create(:user, first_name: 'Steve')}
  let(:john) { create(:user, first_name: 'Jonh') }
  describe 'GET index' do

    context 'with authenticated user' do
      it 'returns accepted and created users' do
        # force lazy evaluation of let to build users
        newguy = User.invite!({:email=>'newguy@test.com'}, john)
        steve
        @auth_headers = john.create_new_auth_token
        get "/users.json", headers: @auth_headers
        expect(response.header['Content-Type']).to include('application/json')
        body = JSON.parse(response.body)
        expect(body[0]["id"]).to eq(john.id)
        expect(body[1]["id"]).to eq(steve.id)
        expect(body.length).to eq(2) #does not have newguy
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        get "/users.json"
        expect(response.status).to eq(401)
      end
    end
  end

  describe 'POST auth_token' do
    context 'with authenticated admin' do
      it 'creates an auth_key if none exist' do
        create(:nilm, admins: [john])
        @auth_headers = john.create_new_auth_token
        post "/users/auth_token.json", headers: @auth_headers
        body = JSON.parse(response.body)
        expect(body['key']).to eq(john.nilm_auth_key.key)
      end
      it 'returns existing auth key' do
        create(:nilm, admins: [john])
        auth_key = NilmAuthKey.create(user: john)
        @auth_headers = john.create_new_auth_token
        post "/users/auth_token.json", headers: @auth_headers
        body = JSON.parse(response.body)
        expect(body['key']).to eq(auth_key.key)
      end
    end
    context 'with authenticated non-admin' do
      it 'returns unauthorized if nilms exist' do
        create(:nilm)
        @auth_headers = john.create_new_auth_token
        post "/users/auth_token.json", headers: @auth_headers
        expect(response.status).to eq(401)
      end
      it 'returns auth key if no nilms exist' do
        @auth_headers = john.create_new_auth_token
        post "/users/auth_token.json", headers: @auth_headers
        body = JSON.parse(response.body)
        expect(body['key']).to eq(john.nilm_auth_key.key)
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        post "/users/auth_token.json"
        expect(response.status).to eq(401)
      end
    end
  end
end
