# frozen_string_literal: true

require 'rails_helper'

describe 'CreateDataView service' do
  let(:viewer) { create(:user) }
  let(:nilm) { create(:nilm, viewers: [viewer]) }
  let(:db) { create(:db, nilm: nilm)}
  let(:viewed_streams) { [
    create(:db_stream, db: db),
    create(:db_stream, db: db)]}

  describe 'successfully' do
    before do
      @params = {
        name: 'test',
        visibility: 'public',
        description: '',
        image: '',
        redux_json: ''}
      @stream_ids = viewed_streams.map {|x| x.id}
      @service = CreateDataView.new
    end
    it 'creates normal data views' do
      @service.run(@params, @stream_ids, viewer)
      expect(@service.success?).to be true
      expect(DataView.count).to eq(1)
      expect(nilm.data_views.count).to eq(1)
      expect(viewer.data_views.count).to eq(1)
    end

    it 'creates user home views' do
      @service.run(@params, @stream_ids, viewer, home_view=true)
      expect(@service.success?).to be true
      view = DataView.first
      expect(viewer.home_data_view).to eq(view)
    end
  end

  it 'returns error if dataview is not valid' do
    params = {description: 'missing name'}
    stream_ids = viewed_streams.map {|x| x.id}
    service = CreateDataView.new
    service.run(params, stream_ids, viewer)
    expect(service.success?).to be false
  end
  it 'returns error if stream_ids are not valid' do
    params = {
      name: 'bad stream ids',
      description: '',
      image: '',
      redux_json: ''}
    stream_ids = [10,11]
    service = CreateDataView.new
    service.run(params, stream_ids, viewer)
    expect(service.success?).to be false
  end

end
