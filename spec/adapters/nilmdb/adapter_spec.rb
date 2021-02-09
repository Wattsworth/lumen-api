# frozen_string_literal: true

require 'rails_helper'

describe Nilmdb::Adapter do


  it 'creates annotations' do
    nilm = FactoryBot.create(:nilm, name: "test")
    stream = FactoryBot.create(:db_stream, db: nilm.db, db_folder: nilm.db.root_folder,
                               name: 'test_stream')
    annotation = FactoryBot.build(:annotation, title: 'test', db_stream: stream)

    adapter = Nilmdb::Adapter.new("url")
    mock_backend = instance_double(Nilmdb::Backend)
    adapter.backend = mock_backend

    expect(mock_backend).to receive(:read_annotations) do
      [{"id" => 100, "title"=> "test"},
       {"id" => 250, "title" => "test"},
       {"id" => 5, "title"=> "test"}]
    end
    expect(mock_backend).to receive(:write_annotations)
    adapter.create_annotation(annotation)
    expect(annotation.id).to eq 251
  end
  it 'creates first annotation' do
    nilm = FactoryBot.create(:nilm, name: "test")
    stream = FactoryBot.create(:db_stream, db: nilm.db, db_folder: nilm.db.root_folder,
                               name: 'test_stream')
    annotation = FactoryBot.build(:annotation, title: 'test', db_stream: stream)

    adapter = Nilmdb::Adapter.new("url")
    mock_backend = instance_double(Nilmdb::Backend)
    adapter.backend = mock_backend

    expect(mock_backend).to receive(:read_annotations) {[]}
    expect(mock_backend).to receive(:write_annotations)
    adapter.create_annotation(annotation)
    expect(annotation.id).to eq 1
  end
  it 'gets annotations' do
    adapter = Nilmdb::Adapter.new("url")
    mock_backend = instance_double(Nilmdb::Backend)
    adapter.backend = mock_backend

    raw = File.read(File.dirname(__FILE__)+"/annotations.json")
    json = JSON.parse(raw)
    expect(mock_backend).to receive(:read_annotations) { json }

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
    nilm = FactoryBot.create(:nilm, name: "test")
    stream = FactoryBot.create(:db_stream, db: nilm.db, db_folder: nilm.db.root_folder,
                               name: 'test_stream')
    annotation = FactoryBot.build(:annotation, title: 'test', db_stream: stream)
    adapter = Nilmdb::Adapter.new("url")
    mock_backend = instance_double(Nilmdb::Backend)
    adapter.backend = mock_backend
    expect(mock_backend).to receive(:read_annotations) do
      [{id: 100, title: "test"},
       {id: 250, title: "test"},
       {id: 5, title: "test"}]
    end
    expect(mock_backend).to receive(:write_annotations)
    adapter.delete_annotation(annotation)
  end

end