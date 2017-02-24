# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UserGroupsController, type: :request do
  let(:grp1) { create(:user_group, name: 'Group1') }
  let(:grp2) { create(:user_group, name: 'Group2') }

  let(:john) { create(:user, first_name: 'Jonh') }

  describe 'GET index' do
    before { john.confirm }

    context 'with authenticated user' do
      it 'returns user groups' do
        # force lazy evaluation of let to build groups
        grp1; grp2;
        @auth_headers = john.create_new_auth_token
        get "/user_groups.json", headers: @auth_headers
        expect(response.header['Content-Type']).to include('application/json')
        body = JSON.parse(response.body)
        expect(body[0]["id"]).to eq(grp1.id)
        expect(body[1]["id"]).to eq(grp2.id)
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
