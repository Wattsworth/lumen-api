# frozen_string_literal: true

require 'rails_helper'

describe Joule::Adapter do

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

    raw = File.read(File.dirname(__FILE__)+"/annotations.json")
    json = JSON.parse(raw)
    expect(mock_backend).to receive(:get_annotations) { json }

    nilm = FactoryBot.create(:nilm, name: "test")
    stream = FactoryBot.create(:db_stream, db: nilm.db, db_folder: nilm.db.root_folder,
                               name: 'test_stream')
    annotations = adapter.get_annotations(stream)
    expect(annotations.length).to eq 6
    annotations.each do | annotation |
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