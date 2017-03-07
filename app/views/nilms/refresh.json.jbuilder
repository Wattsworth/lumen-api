# frozen_string_literal: true
json.data do
  json.extract! @nilm, *Nilm.json_keys
  unless @nilm.db.nil?
    json.db_id @nilm.db.id
    json.available @nilm.db.available
    #show the database which was refreshed
    json.db do
      json.partial! 'dbs/db', db: @nilm.db
    end
  end
end
json.partial! 'helpers/messages', service: @service
