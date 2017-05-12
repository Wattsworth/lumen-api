require 'rails_helper'

RSpec.describe DataViewsController, type: :request do

  let(:viewer) { create(:user)}
  let(:nilm) { create(:nilm, name: 'my_nilm', viewers: [viewer]) }
  let(:db) { create(:db, nilm: nilm)}
  let(:viewed_streams) { [
    create(:db_stream, db: db),
    create(:db_stream, db: db)]}

  describe 'GET index' do
    context 'with authenticated user' do
      it 'returns all loadable data views' do
        other_nilm = create(:nilm, name: 'other_nilm')
        other_db = create(:db, nilm: other_nilm)
        other_stream = create(:db_stream, db: other_db)
        other_user = create(:user)
        service = CreateDataView.new
        allowed_view = service.run(
          {name: 'allowed'}, [viewed_streams.first.id], other_user)
        prohibited_view = service.run(
          {name: 'prohibited'}, [other_stream.id], other_user)
        my_view = service.run(
          {name: 'created'}, viewed_streams.map{|x| x.id}, viewer)
        #viewer should receive 'allowed' and 'created'
        @auth_headers = viewer.create_new_auth_token
        get "/data_views.json", headers: @auth_headers
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body.length).to eq 2
        body.each do |view|
          if view['name']=='created'
            expect(view['owner']).to be true
          else
            expect(view['owner']).to be false
          end
        end
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        get "/data_views.json"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST create' do
    context 'with authenticated user' do
      it 'creates a dataview' do
        @auth_headers = viewer.create_new_auth_token
        post "/data_views.json",
          params: {
            name: 'test', description: '', image: '', redux_json: '',
            stream_ids: viewed_streams.map {|x| x.id}
          }, headers: @auth_headers
        expect(response).to have_http_status(:ok)
        expect(response).to have_notice_message
        body = JSON.parse(response.body)
        #viewer should own this new dataview
        expect(body['data']['owner']).to be(true)
      end
      it 'returns error with bad parameters' do
        @auth_headers = viewer.create_new_auth_token
        post "/data_views.json",
          params: {
            description: 'missing name', image: '', redux_json: '',
            stream_ids: viewed_streams.map {|x| x.id}
          }, headers: @auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to have_error_message
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        post "/data_views.json"
        expect(response.status).to eq(401)
      end
    end
  end
end
