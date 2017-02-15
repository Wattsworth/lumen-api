# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NilmsController, type: :request do
  let(:john) { create(:user, first_name: 'John') }
  let(:steve) { create(:user, first_name: 'Steve') }
  let(:john_nilm) { create(:nilm, name: "John's NILM", admins: [john]) }
  let(:lab_nilm) { create(:nilm, name: 'Lab NILM', owners: [john]) }
  let(:pete_nilm) { create(:nilm, name: "Pete's NILM", viewers: [john])}
  let(:hidden_nilm) { create(:nilm, name: "Private NILM", owners: [steve])}

  describe 'GET index' do
    before do
      john.confirm
      steve.confirm
    end
    context 'with authenticated user' do
      it 'returns authorized nilms' do
        # force lazy evaluation of let to build NILMs
        john_nilm; pete_nilm; lab_nilm; hidden_nilm
        @auth_headers = john.create_new_auth_token
        get "/nilms.json", headers: @auth_headers
        expect(response.header['Content-Type']).to include('application/json')
        body = JSON.parse(response.body)
        expect(body["admin"][0]["id"]).to eq(john_nilm.id)
        expect(body["owner"][0]["id"]).to eq(lab_nilm.id)
        expect(body["viewer"][0]["id"]).to eq(pete_nilm.id)
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        get "/nilms.json"
        expect(response.status).to eq(401)
      end
    end
  end


  describe 'PUT update' do
    before do
      john.confirm
      steve.confirm
    end
    context 'with owner permissions' do
      it 'updates parameters' do
        @auth_headers = john.create_new_auth_token
        [john_nilm, lab_nilm].each do |nilm|
          put "/nilms/#{nilm.id}.json",
              params: {id: nilm.id, name: "changed:#{nilm.id}"},
              headers: @auth_headers
          expect(response.status).to eq(200)
          expect(response).to have_notice_message
          expect(nilm.reload.name).to eq("changed:#{nilm.id}")
        end
      end
      it 'returns 422 on invalid parameters' do
        @auth_headers = john.create_new_auth_token
        put "/nilms/#{john_nilm.id}.json",
            params: {id: john_nilm.id, name: ""},
            headers: @auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(john_nilm.reload.name).to eq("John's NILM")
      end
    end
    context 'without admin permissions' do
      it 'returns unauthorized' do
        @auth_headers = john.create_new_auth_token
        put "/nilms/#{pete_nilm.id}.json",
            params: {id: pete_nilm.id, name: "test"},
            headers: @auth_headers
        expect(response).to have_http_status(:unauthorized)
        expect(pete_nilm.reload.name).to eq("Pete's NILM")
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        put "/nilms/#{pete_nilm.id}.json",
            params: {id: pete_nilm.id, name: "test"}
        expect(response).to have_http_status(:unauthorized)
        expect(pete_nilm.reload.name).to eq("Pete's NILM")
      end
    end
  end

  describe 'GET show' do
    before do
      john.confirm
      steve.confirm
    end
    context 'with any permissions' do
      it 'returns the nilm as json' do
        # john has some permission on all 3 nilms
        @auth_headers = john.create_new_auth_token
        [pete_nilm, lab_nilm, john_nilm].each do |nilm|
          get "/nilms/#{nilm.id}.json",
              headers: @auth_headers
          expect(response.status).to eq(200)
          expect(response.header['Content-Type']).to include('application/json')
          body = JSON.parse(response.body)
          expect(body['name']).to eq(nilm.name)
        end
      end
    end
    context 'without permissions' do
      it 'returns unauthorized' do
        # steve does NOT have permissions on john_nilm
        @auth_headers = steve.create_new_auth_token
        get "/nilms/#{john_nilm.id}.json",
            headers: @auth_headers
        expect(response.status).to eq(401)
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        #  no headers: nobody is signed in, deny all
        get "/nilms/#{john_nilm.id}.json"
        expect(response.status).to eq(401)
      end
    end
  end
end
