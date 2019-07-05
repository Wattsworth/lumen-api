require 'rails_helper'

RSpec.describe AnnotationsController, type: :request do

  let(:owner) { create(:user, first_name: 'Owner') }
  let(:admin) { create(:user, first_name: 'Admin')}
  let(:viewer) { create(:user, first_name: 'Viewer')}
  let(:user) { create(:user, first_name: 'User')}
  let(:nilm) do  create(:nilm, name: "Test NILM", node_type: 'joule',
                        admins: [admin], owners: [owner], viewers: [viewer])
  end
  let(:db) {create(:db, nilm: nilm)}
  let(:stream) {create(:db_stream, db: db)}

  describe 'GET #annotations' do
    # retrieve annotations for a given stream
    context 'with authorized user' do

      it 'returns all annotations' do
        annotations = build_list(:annotation, 10, db_stream: stream)
        mock_adapter = instance_double(Joule::Adapter)
        expect(mock_adapter).to receive(:get_annotations).and_return(annotations)
        allow(NodeAdapterFactory).to receive(:from_nilm).and_return(mock_adapter)

        get "/db_streams/#{stream.id}/annotations.json", headers: user.create_new_auth_token
        expect(response.header['Content-Type']).to include('application/json')
        body = JSON.parse(response.body)
        expect(body['data'].length).to eq 10
        body['data'].each do |annotation|
          expect(annotation['db_stream_id']).to eq stream.id
          expect(annotation).to include('id', 'title', 'content', 'start', 'end')
        end
      end
      it 'returns error message if backend fails' do
        mock_adapter = instance_double(Joule::Adapter)
        expect(mock_adapter).to receive(:get_annotations).and_raise(RuntimeError.new('test'))
        allow(NodeAdapterFactory).to receive(:from_nilm).and_return(mock_adapter)
        get "/db_streams/#{stream.id}/annotations.json", headers: user.create_new_auth_token
        expect(response.header['Content-Type']).to include('application/json')
        body = JSON.parse(response.body)
        expect(body['messages']['errors']).to include('test')
      end
      it 'returns error message if backend is not available' do
        allow(NodeAdapterFactory).to receive(:from_nilm).and_return(nil)
        get "/db_streams/#{stream.id}/annotations.json", headers: user.create_new_auth_token
        expect(response.header['Content-Type']).to include('application/json')
        body = JSON.parse(response.body)
        expect(body['messages']['errors']).to include('Cannot contact installation')
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        get "/db_streams/#{stream.id}/annotations.json"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST #annotations' do
    # create a new annotation for a stream
    context 'with owner' do
      it 'creates annotations' do
        mock_adapter = instance_double(Joule::Adapter)
        expect(mock_adapter).to receive(:create_annotation) do |annotation|
          expect(annotation.title).to eq "Title"
          expect(annotation.content).to eq "Content"
          expect(annotation.db_stream.id).to eq stream.id
          expect(annotation.start_time).to eq 100
          expect(annotation.end_time).to be 200
        end
        allow(NodeAdapterFactory).to receive(:from_nilm).and_return(mock_adapter)
        post "/db_streams/#{stream.id}/annotations.json", headers: owner.create_new_auth_token,
             params: {
               title: "Title",
               content: "Content",
               start: 100,
               end: 200}
        body = JSON.parse(response.body)
        expect(body['data'].length).to eq 1
        expect(body['data'][0]['title']).to eq 'Title'
      end

      it 'returns error if backend fails' do
        mock_adapter = instance_double(Joule::Adapter)
        expect(mock_adapter).to receive(:create_annotation).and_raise(RuntimeError.new('test'))
        allow(NodeAdapterFactory).to receive(:from_nilm).and_return(mock_adapter)
        post "/db_streams/#{stream.id}/annotations.json", headers: owner.create_new_auth_token
        expect(response.header['Content-Type']).to include('application/json')
        body = JSON.parse(response.body)
        expect(body['messages']['errors']).to include('test')
      end
    end

    context 'with viewer' do
      it 'returns unauthorized' do
        post "/db_streams/#{stream.id}/annotations.json", headers: viewer.create_new_auth_token
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with anyone else' do
      it 'returns unauthorized' do
        post "/db_streams/#{stream.id}/annotations.json", headers: user.create_new_auth_token
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'without sign-in' do
      it 'returns unauthorized' do
        post "/db_streams/#{stream.id}/annotations.json"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DESTROY #annotations' do
    # deletes specified annotation
    context 'with owner' do
      it 'deletes the annotation' do
        mock_adapter = instance_double(Joule::Adapter)
        expect(mock_adapter).to receive(:delete_annotation) do |id|
          expect(id).to eq 10
        end
        allow(NodeAdapterFactory).to receive(:from_nilm).and_return(mock_adapter)
        delete "/db_streams/#{stream.id}/annotations/10.json",
               headers: owner.create_new_auth_token
        expect(response.header['Content-Type']).to include('application/json')
        body = JSON.parse(response.body)
        expect(body['messages']['errors'].empty?).to be true

      end
      it 'returns error if backend fails' do
        mock_adapter = instance_double(Joule::Adapter)
        expect(mock_adapter).to receive(:delete_annotation).and_raise(RuntimeError.new('test'))
        allow(NodeAdapterFactory).to receive(:from_nilm).and_return(mock_adapter)
        delete "/db_streams/#{stream.id}/annotations/10.json", headers: owner.create_new_auth_token
        expect(response.header['Content-Type']).to include('application/json')
        body = JSON.parse(response.body)
        expect(body['messages']['errors']).to include('test')
      end
    end

    context 'with viewer' do
      it 'returns unauthorized' do
        delete "/db_streams/#{stream.id}/annotations/10.json", headers: viewer.create_new_auth_token
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'with anyone else' do
      it 'returns unauthorized' do
        delete "/db_streams/#{stream.id}/annotations/10.json", headers: user.create_new_auth_token
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        delete "/db_streams/#{stream.id}/annotations/10.json"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

end
