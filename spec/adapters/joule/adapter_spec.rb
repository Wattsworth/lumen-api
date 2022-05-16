# frozen_string_literal: true

require 'rails_helper'

describe Joule::Adapter do

  it 'reads events' do
    adapter = Joule::Adapter.new("url", "key")
    mock_backend = instance_double(Joule::Backend)
    adapter.backend = mock_backend

    raw = File.read(File.dirname(__FILE__) + "/events.json")
    json = JSON.parse(raw)
    json.deep_symbolize_keys!
    expect(mock_backend).to receive(:read_events) { json }

    nilm = FactoryBot.create(:nilm, name: "test")
    stream = FactoryBot.create(:event_stream, db: nilm.db, db_folder: nilm.db.root_folder,
                               name: 'test_stream')
    result = adapter.read_events(stream, 200, 1611421200000000, 1611421230000000, [])
    expect(result[:id]).to eq stream.id
    expect(result[:valid]).to be true
    expect(result[:events].length).to eq 4
    expected_event = {
        start_time: 1611421200000000,
        end_time: 1611421205000000,
        content: {name: "test event 0"}}
    expect(result[:events][0]).to eq expected_event
  end

  it 'creates annotations' do
    annotation = Annotation.new
    annotation.title = "test"
    adapter = Joule::Adapter.new("url", "key")
    mock_backend = instance_double(Joule::Backend)
    adapter.backend = mock_backend

    expect(mock_backend).to receive(:create_annotation) { annotation }
    resp = adapter.create_annotation(annotation)
    expect(resp).to eq annotation
  end
  it 'gets annotations' do
    adapter = Joule::Adapter.new("url", "key")
    mock_backend = instance_double(Joule::Backend)
    adapter.backend = mock_backend

    raw = File.read(File.dirname(__FILE__) + "/annotations.json")
    json = JSON.parse(raw)
    expect(mock_backend).to receive(:get_annotations) { json }

    nilm = FactoryBot.create(:nilm, name: "test")
    stream = FactoryBot.create(:db_stream, db: nilm.db, db_folder: nilm.db.root_folder,
                               name: 'test_stream')
    annotations = adapter.get_annotations(stream)
    expect(annotations.length).to eq 6
    annotations.each do |annotation|
      expect(annotation.db_stream).to be stream
    end
  end

  it 'deletes annotations' do
    adapter = Joule::Adapter.new("url", "key")
    mock_backend = instance_double(Joule::Backend)
    adapter.backend = mock_backend
    annotation = FactoryBot.build(:annotation)
    annotation.id = 3
    expect(mock_backend).to receive(:delete_annotation)
    adapter.delete_annotation(annotation)
  end

end