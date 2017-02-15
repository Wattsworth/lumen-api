json.data do
  json.partial! "nilms/nilm", nilm: @nilm
end

json.partial! "helpers/messages", service: @service
