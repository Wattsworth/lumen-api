# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UserGroupsController, type: :request do
  let(:grp1) { create(:user_group, name: 'Group1') }
  let(:grp2) { create(:user_group, name: 'Group2') }
  let(:donnals) { create(:user_group, name: 'Donnals',
    owner: john, members: [nicky])}
  let(:john) { create(:user, first_name: 'Jonh') }
  let(:nicky) { create(:user, first_name: 'Nicky')}
  let(:steve) { create(:user, first_name: 'Steve')}

  describe 'GET index' do
    before do
      john.confirm
      # force lazy evaluation of let to build groups
      grp1; grp2; donnals;
    end

    context 'with john' do
      it 'returns 1 owner, 0 members, 2 others' do
        @auth_headers = john.create_new_auth_token
        get "/user_groups.json", headers: @auth_headers
        expect(response.header['Content-Type']).to include('application/json')
        body = JSON.parse(response.body)
        expect(body["owner"].length).to eq(1)
        expect(body["owner"][0]["members"].length).to eq(1)
        expect(body["member"].length).to eq(0)
        expect(body["other"].length).to eq(2)
      end
    end
    context 'with nicky' do
      it 'returns 0 owners, 1 member, 2 others' do
        @auth_headers = nicky.create_new_auth_token
        get "/user_groups.json", headers: @auth_headers
        expect(response.header['Content-Type']).to include('application/json')
        body = JSON.parse(response.body)
        expect(body["owner"].length).to eq(0)
        expect(body["member"].length).to eq(1)
        expect(body["other"].length).to eq(2)
      end
    end
    context 'with steve' do
      it 'returns 0 owners, 0 members, 3 others' do
        @auth_headers = steve.create_new_auth_token
        get "/user_groups.json", headers: @auth_headers
        expect(response.header['Content-Type']).to include('application/json')
        body = JSON.parse(response.body)
        expect(body["owner"].length).to eq(0)
        expect(body["member"].length).to eq(0)
        expect(body["other"].length).to eq(3)
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        get "/user_groups.json"
        expect(response.status).to eq(401)
      end
    end
  end
end
