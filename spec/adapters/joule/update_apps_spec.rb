# frozen_string_literal: true

require 'rails_helper'

describe Joule::UpdateApps do

  it 'updates apps and maintains common id values' do
    nilm = FactoryBot.create(:nilm, name: 'test nilm')
    updater = Joule::UpdateApps.new(nilm)
    raw = File.read(File.dirname(__FILE__)+"/apps.json")
    json = JSON.parse(raw)
    json.each do |item|
      item.symbolize_keys!
    end
    updater.run(json)
    app_ids = nilm.data_apps.map {|app| app.id}
    # parses all three apps
    expect(app_ids.length).to eq 3
    # running with the same app json doesn't change the ID values
    updater.run(json)
    new_app_ids = nilm.data_apps.map {|app| app.id}
    expect(new_app_ids).to eq app_ids
    # removes unused apps
    nilm.data_apps << DataApp.new(name: 'unused app', joule_id: 'm5')
    expect(nilm.data_apps.length).to eq 4
    updater.run(json)
    nilm.data_apps.reload
    new_app_ids = nilm.data_apps.map {|app| app.id}
    expect(new_app_ids).to eq app_ids


  end

end