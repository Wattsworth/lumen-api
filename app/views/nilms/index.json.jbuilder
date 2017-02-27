# frozen_string_literal: true
json.admin @nilms[:admin] do |nilm|
  json.extract! nilm, *Nilm.json_keys
  json.db_id nilm.db.id
  json.available nilm.db.available
end
json.owner @nilms[:owner] do |nilm|
  json.extract! nilm, *Nilm.json_keys
  json.db_id nilm.db.id
  json.available nilm.db.available
end
json.viewer @nilms[:viewer] do |nilm|
  json.extract! nilm, *Nilm.json_keys
  json.db_id nilm.db.id
  json.available nilm.db.available
end
