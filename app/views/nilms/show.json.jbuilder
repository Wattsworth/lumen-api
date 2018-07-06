# frozen_string_literal: true
json.data do
  json.extract! @nilm, *Nilm.json_keys
  json.role @role
  json.max_points_per_plot @nilm.db.max_points_per_plot
  json.root_folder do
    json.partial! 'db_folders/db_folder',
                  db_folder: @nilm.db.root_folder,
                  nilm: @nilm
  end
  json.jouleModules(@nilm.joule_modules) do |m|
    json.extract! m, *JouleModule.json_keys
    json.nilm_id @nilm.id
  end
end
json.partial! 'helpers/messages', service: @service
