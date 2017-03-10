require 'rails_helper'

RSpec.describe PermissionsController, type: :request do
  let(:john) { create(:confirmed_user, first_name: 'John') }
  let(:nicky) { create(:confirmed_user, first_name: 'Nicky')}
  let(:steve) { create(:confirmed_user, first_name: 'Steve') }
  let(:pete) { create(:confirmed_user, first_name: 'Pete') }
  let(:john_nilm) { create(:nilm, name: "John's NILM",
                                  admins: [john],
                                  owners: [nicky],
                                  viewers: [steve]) }

  describe 'GET #index' do
    # list permissions by nilm
    context 'with admin privileges' do
      it 'returns nilm permissions' do
        @auth_headers = john.create_new_auth_token
        get "/permissions.json",
          params: {nilm_id: john_nilm.id},
          headers: @auth_headers
        expect(response).to have_http_status(:ok)
        expect(response.header['Content-Type']).to include('application/json')
        permissions = JSON.parse(response.body)
        expect(permissions.count).to eq(3)
      end
    end
    context 'without admin privileges' do
      it 'returns unauthorized' do
        [nicky,steve].each do |user|
          @auth_headers = user.create_new_auth_token
          get "/permissions.json",
              params: {nilm_id: john_nilm.id},
              headers: @auth_headers
              expect(response).to have_http_status(:unauthorized)
        end
      end
      it 'returns not found on bad nilm id' do
        # nilm 99 does not exist
        @auth_headers = steve.create_new_auth_token
        get "/permissions.json",
            params: {nilm_id: 99},
            headers: @auth_headers
            expect(response).to have_http_status(:not_found)
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        #  no headers: nobody is signed in, deny all
        get "/permissions.json"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST #create' do
    # add permissions to specified nilm
    context 'with admin privileges' do
      it 'adds new permission' do
        @auth_headers = john.create_new_auth_token
        post "/permissions.json",
          params: {nilm_id: john_nilm.id,
                   role: 'viewer',
                   target: 'user',
                   target_id: pete.id},
          headers: @auth_headers
        expect(response).to have_http_status(:ok)
        expect(response.header['Content-Type']).to include('application/json')
        expect(response).to have_notice_message
        expect(pete.views_nilm?(john_nilm)).to be true
      end
      it 'returns errors on invalid request' do
        # steve already has permissions on this nilm
        @auth_headers = john.create_new_auth_token
        post "/permissions.json",
          params: {nilm_id: john_nilm.id,
                   role: 'owner',
                   target: 'user',
                   target_id: steve.id},
          headers: @auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.header['Content-Type']).to include('application/json')
        expect(response).to have_error_message
      end
    end
    context 'without admin privileges' do
      it 'returns unauthorized' do
        [nicky,steve].each do |user|
          @auth_headers = user.create_new_auth_token
          post "/permissions.json",
              params: {nilm_id: john_nilm.id},
              headers: @auth_headers
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        #  no headers: nobody is signed in, deny all
        post "/permissions.json"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT #create_user' do
    context 'with admin privileges' do
      it 'creates user with specified permission' do
        @auth_headers = john.create_new_auth_token
        put "/permissions/create_user.json",
          params: {nilm_id: john_nilm.id,
                   role: 'viewer',
                   first_name: 'bill', last_name: 'will',
                   email: 'valid@url.com', password: 'poorchoice',
                   password_confirmation: 'poorchoice'},
          headers: @auth_headers
        expect(response).to have_http_status(:ok)
        expect(response).to have_notice_message
        user = User.find_by_email('valid@url.com')
        expect(user.views_nilm?(john_nilm)).to be true
      end
      it 'returns error if user cannot be created' do
        #password does not match confirmation
        @auth_headers = john.create_new_auth_token
        put "/permissions/create_user.json",
          params: {nilm_id: john_nilm.id,
                   role: 'viewer',
                   first_name: 'bill', last_name: 'will',
                   email: 'valid@url.com', password: 'poorchoice',
                   password_confirmation: 'error'},
          headers: @auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to have_error_message
        user = User.find_by_email('valid@url.com')
        expect(user).to be nil
      end
    end
    context 'with anyone else' do
      it 'returns unauthorized' do
        #password does not match confirmation
        @auth_headers = steve.create_new_auth_token
        put "/permissions/create_user.json",
          params: {nilm_id: john_nilm.id,
                   role: 'viewer',
                   first_name: 'bill', last_name: 'will',
                   email: 'valid@url.com', password: 'poorchoice',
                   password_confirmation: 'error'},
          headers: @auth_headers
        expect(response).to have_http_status(:unauthorized)
        user = User.find_by_email('valid@url.com')
        expect(user).to be nil
      end
    end
    context 'without signin' do
      it 'returns unauthorized' do
        #password does not match confirmation
        put "/permissions/create_user.json",
          params: {nilm_id: john_nilm.id,
                   role: 'viewer',
                   first_name: 'bill', last_name: 'will',
                   email: 'valid@url.com', password: 'poorchoice',
                   password_confirmation: 'error'}
        expect(response).to have_http_status(:unauthorized)
        user = User.find_by_email('valid@url.com')
        expect(user).to be nil
      end
    end
  end


  describe 'DELETE #destroy' do
    # removes specified permission from nilm
    context 'with admin privileges' do
      it 'removes permission' do
        p = Permission.where(nilm: john_nilm, user: steve).first
        expect(steve.views_nilm?(john_nilm)).to be true
        @auth_headers = john.create_new_auth_token
        delete "/permissions/#{p.id}.json",
          params: {nilm_id: john_nilm.id},
          headers: @auth_headers
        expect(response).to have_http_status(:ok)
        expect(response.header['Content-Type']).to include('application/json')
        expect(response).to have_notice_message
        expect(steve.views_nilm?(john_nilm)).to be false
      end
      it 'returns error on invalid request' do
        # cannot remove your own permission
        p = Permission.where(nilm: john_nilm, user: john).first
        @auth_headers = john.create_new_auth_token
        delete "/permissions/#{p.id}.json",
          params: {nilm_id: john_nilm.id},
          headers: @auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.header['Content-Type']).to include('application/json')
        expect(response).to have_error_message
        expect(john.admins_nilm?(john_nilm)).to be true
      end
    end
    context 'without admin privileges' do
      it 'returns unauthorized' do
        [nicky,steve].each do |user|
          @auth_headers = user.create_new_auth_token
          delete "/permissions/99.json",
              params: {nilm_id: john_nilm.id},
              headers: @auth_headers
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        #  no headers: nobody is signed in, deny all
        delete "/permissions/99.json"
        expect(response).to have_http_status(:unauthorized)
      end
    end

  end


end
