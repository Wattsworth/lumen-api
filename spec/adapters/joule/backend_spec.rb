# frozen_string_literal: true

require 'rails_helper'

describe Joule::Backend do
  # use the benchtop server joule API
  let (:url) {'http://nuc:8088'}
  let (:key) {'api_key'}
  it 'retrieves database schema', :vcr do
    url = 'https://localhost:3030'
    key = 'apkQ3_tvTo-bCzFrIADW2uvlZ6nboISwC6tvsoH64mc'
    backend = Joule::Backend.new(url, key)
    schema = backend.db_schema
    # make sure keys are symbolized
    expect(schema).to include(:name, :id, :streams, :children)
    # should be a tree structure
    expect(schema[:children][0]).to include(:name, :id, :streams, :event_streams, :children)
  end
  it 'retrieves module schema', :vcr do
    backend = Joule::Backend.new(url, key)
    backend.module_schemas.each do |m|
      expect(m).to include(:name, :inputs, :outputs)
    end
  end

  it 'loads raw data', :vcr do
    backend = Joule::Backend.new(url, key)
    resp = backend.load_data(6,
                             1531248642561047,
                             1531248642581047,
                             200)
    expect(resp[:success]).to be true
    expect(resp[:result][:decimated]).to be false
    expect(resp[:result][:data].count).to be > 0
    expect(resp[:result][:data].count).to be < 200
  end

  it 'loads decimated data', :vcr do
    backend = Joule::Backend.new(url, key)
    resp = backend.load_data(6,
                             1531248642561047,
                             1531330705273202,
                             20)
    expect(resp[:success]).to be true
    expect(resp[:result][:decimated]).to be true
    expect(resp[:result][:data].count).to be > 0
    expect(resp[:result][:data].count).to be < 200
  end

  describe "Events" do
    let(:url) { "https://127.0.0.1:3030"}
    let(:key) { "apkQ3_tvTo-bCzFrIADW2uvlZ6nboISwC6tvsoH64mc"}
    describe "read_events" do
      it 'loads events', :vcr do
        backend = Joule::Backend.new(url, key)
        start_time = 1611421210000000
        end_time = 1611421235000000
        events = backend.read_events(2, start_time, end_time)
        # should have 3 events
        expect(events.length).to eq 3
        expected_event = {
            "start_time":1611421210000000,
            "end_time":1611421215000000,
            "content":{
                "name":"test event 1"}}
        expect(events[0]).to eq expected_event
      end
      it 'handles errors', :vcr do
        backend = Joule::Backend.new(url, key)
        # server was stopped for this request
        expect{backend.get_annotations(101)}.to raise_error(RuntimeError)
      end
    end
  end

  describe "Annotations" do
    let(:url) { "https://172.34.31.8:8088"}
    let(:key) { "cR0JqqTM8bizW73MY1IAHCPJUTwDmOdunhYK9b2VQ98"}
    describe "get_annotations" do
      it 'loads annotations', :vcr do
        backend = Joule::Backend.new(url, key)
        annotations = backend.get_annotations(2646)
        # should have 6 annotations, first one is an event
        expect(annotations[0]["end"]).to be nil
        expect(annotations.length).to eq 6
      end

      it 'handles errors', :vcr do
        backend = Joule::Backend.new(url, key)
        # server was stopped for this request
        expect{backend.get_annotations(101)}.to raise_error(RuntimeError)
      end
    end
    describe "delete_annotation" do
      it 'deletes annotations', :vcr do
        backend = Joule::Backend.new(url, key)
        annotations = backend.get_annotations(2646)
        num_annotations = annotations.length
        backend.delete_annotation(28)
        annotations = backend.get_annotations(2646)
        new_num_annotations = annotations.length
        expect(new_num_annotations).to equal num_annotations-1
      end
    end

    describe "create_annotation" do
      it 'creates annotations', :vcr do
        backend = Joule::Backend.new(url, key)
        nilm = FactoryBot.create(:nilm, name: "test")
        stream = FactoryBot.create(:db_stream, db: nilm.db, db_folder: nilm.db.root_folder,
                                   name: 'test_stream')
        stream.joule_id = 2646
        annotation = FactoryBot.build(:annotation, db_stream: stream)
        backend.create_annotation(annotation)
        expect(annotation.id).to_not be nil
      end
    end
  end
end

