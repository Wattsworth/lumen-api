# frozen_string_literal: true
json.data do
  json.extract! @nilm, *Nilm.json_keys
  json.role @role
  unless @nilm.db.nil?
    json.partial! "db", db: @nilm.db, as: :db
    json.available @nilm.db.available
  end
  json.joule_modules(@nilm.joule_modules) do |m|
    json.extract! m, *JouleModule.json_keys
    json.url @url_template % [m.id]
    json.nilm_id @nilm.id
  end
end
json.partial! 'helpers/messages', service: @service
