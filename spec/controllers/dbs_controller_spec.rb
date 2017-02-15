# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DbsController, type: :request do
  let(:john) { create(:user, first_name: 'John') }
  let(:steve) { create(:user, first_name: 'Steve') }
  let(:john_nilm) { create(:nilm, name: "John's NILM", admins: [john]) }
  let(:lab_nilm) { create(:nilm, name: 'Lab NILM', owners: [john]) }
  let(:pete_nilm) { create(:nilm, name: "Pete's NILM", viewers: [john])}
  let(:hidden_nilm) { create(:nilm, name: "Private NILM", owners: [steve])}

  # index action does not exist

  describe 'GET show' do
    before do
      john.confirm
      steve.confirm
    end
    context 'with any permissions' do
      it 'returns the db as json' do
        # john has some permission on all 3 nilms
        @auth_headers = john.create_new_auth_token
        [pete_nilm.db, lab_nilm.db, john_nilm.db].each do |db|
          get "/dbs/#{db.id}.json",
              headers: @auth_headers
          expect(response.status).to eq(200)
          expect(response.header['Content-Type']).to include('application/json')
          body = JSON.parse(response.body)
          expect(body['url']).to eq(db.url)
        end
      end
    end
    context 'without permissions' do
      it 'returns unauthorized' do
        # steve does NOT have permissions on john_nilm
        @auth_headers = steve.create_new_auth_token
        get "/dbs/#{john_nilm.db.id}.json",
            headers: @auth_headers
        expect(response.status).to eq(401)
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        #  no headers: nobody is signed in, deny all
        get "/dbs/#{john_nilm.db.id}.json"
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
      it 'refreshes db if URL is changed or refresh paramter is set' do

      end
      it 'returns 422 on invalid parameters' do
        # max points must be a positive number
        @auth_headers = john.create_new_auth_token
        put "/dbs/#{john_nilm.db.id}.json",
            params: {max_points_per_plot: 'invalid'},
            headers: @auth_headers
        expect(response.status).to eq(422)
        expect(response).to have_error_message(/not a number/)
      end

      it 'only allows configurable parameters to be changed' do
        # should ignore size and accept max_points
        @auth_headers = john.create_new_auth_token
        size = john_nilm.db.size_db
        num_points = pete_nilm.db.max_points_per_plot
        put "/dbs/#{john_nilm.db.id}.json",
            params: {max_points_per_plot: num_points+10, size_db: size+10},
            headers: @auth_headers
        expect(response.status).to eq(200)
        expect(response).to have_notice_message()
        expect(john_nilm.db.reload.size_db).to eq(size)
        expect(john_nilm.db.max_points_per_plot).to eq(num_points+10)
      end
    end
    context 'without admin permissions' do
      it 'returns unauthorized' do
        @auth_headers = john.create_new_auth_token
        num_points = pete_nilm.db.max_points_per_plot
        put "/dbs/#{pete_nilm.db.id}.json",
            params: {max_points_per_plot: num_points+10},
            headers: @auth_headers
        expect(response).to have_http_status(:unauthorized)
        expect(pete_nilm.db.max_points_per_plot).to eq(num_points)
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        num_points = pete_nilm.db.max_points_per_plot
        put "/dbs/#{pete_nilm.db.id}.json",
            params: {max_points_per_plot: num_points+10}
        expect(response).to have_http_status(:unauthorized)
        expect(pete_nilm.db.max_points_per_plot).to eq(num_points)
      end
    end
  end
end
