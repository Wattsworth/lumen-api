# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UserGroupsController, type: :request do
  let(:owner) { create(:user) }
  let(:member1) { create(:user) }
  let(:member2) { create(:user) }
  let(:other_user) { create(:user) }
  let(:group) do
    create(:user_group,
           owner: owner,
           members: [member1, member2])
end


  describe 'GET index' do
    let(:grp1) { create(:user_group, name: 'Group1') }
    let(:grp2) { create(:user_group, name: 'Group2') }
    let(:donnals) { create(:user_group, name: 'Donnals',
      owner: john, members: [nicky])}
    let(:john) { create(:confirmed_user, first_name: 'Jonh') }
    let(:nicky) { create(:confirmed_user, first_name: 'Nicky')}
    let(:steve) { create(:confirmed_user, first_name: 'Steve')}

    before do
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

  describe 'PUT add_member' do

    context 'with owner' do
      it 'adds a member' do
        @auth_headers = owner.create_new_auth_token
        put "/user_groups/#{group.id}/add_member.json",
          params: { user_id: other_user.id},
          headers: @auth_headers
        expect(response.status).to eq(200)
        expect(group.reload.users.include?(other_user)).to be true
        expect(response).to have_notice_message
        #check to make sure JSON renders the members
        body = JSON.parse(response.body)
        expect(body['data']['members'].count).to eq group.users.count
      end
      it 'returns error on invalid request' do
        @auth_headers = owner.create_new_auth_token
        # member1 is already a member
        put "/user_groups/#{group.id}/add_member.json",
          params: { user_id: member1.id},
          headers: @auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to have_error_message
      end
    end
    context 'with anyone else' do
      it 'returns unauthorized' do
        @auth_headers = member1.create_new_auth_token
        put "/user_groups/#{group.id}/add_member.json",
          params: { user_id: other_user.id},
          headers: @auth_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        put "/user_groups/#{group.id}/add_member.json",
          params: { user_id: other_user.id}
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT remove_member' do
    context 'with owner' do
      it 'removes a member' do
        @auth_headers = owner.create_new_auth_token
        put "/user_groups/#{group.id}/remove_member.json",
          params: { user_id: member1.id},
          headers: @auth_headers
        expect(response.status).to eq(200)
        expect(group.reload.users.include?(member1)).to be false
        expect(response).to have_notice_message
        #check to make sure JSON renders the members
        body = JSON.parse(response.body)
        expect(body['data']['members'].count).to eq group.users.count
      end
      it 'returns error on invalid request' do
        @auth_headers = owner.create_new_auth_token
        # other_user is not a member
        put "/user_groups/#{group.id}/remove_member.json",
          params: { user_id: other_user.id},
          headers: @auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to have_error_message
      end
    end
    context 'with anyone else' do
      it 'returns unauthorized' do
        @auth_headers = member1.create_new_auth_token
        put "/user_groups/#{group.id}/remove_member.json",
          params: { user_id: member2.id},
          headers: @auth_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        put "/user_groups/#{group.id}/remove_member.json",
          params: { user_id: other_user.id}
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
