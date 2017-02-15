# expects service to be a service object
json.messages do
  json.notices service.notices
  json.warnings service.warnings
  json.errors service.errors
end
