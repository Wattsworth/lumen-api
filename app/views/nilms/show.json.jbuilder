# frozen_string_literal: true
json.data do
  json.extract! @nilm, *Nilm.json_keys
  unless @nilm.db.nil?
    json.db_id @nilm.db.id
    json.available @nilm.db.available
  end
end
json.partial! 'helpers/messages', service: @service
