# frozen_string_literal: true
json.data do
  json.extract! @nilm, *Nilm.json_keys
  json.role @role
  if @nilm.db != nil
    json.max_points_per_plot @nilm.db.max_points_per_plot
    json.available @nilm.db.available
    json.root_folder do
      if @nilm.db.root_folder != nil
        json.partial! 'db_folders/db_folder',
                      db_folder: @nilm.db.root_folder,
                      nilm: @nilm
      end
    end
  end
  json.data_apps(@nilm.data_apps) do |app|
    json.id app.id
    json.name app.name
    json.url Rails.configuration.app_proxy_url.call(app.id)
    json.nilm_id @nilm.id
  end
end
json.partial! 'helpers/messages', service: @service
