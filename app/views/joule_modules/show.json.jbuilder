
json.extract! @joule_module, *JouleModule.json_keys
json.nilm_id @nilm.id
if @joule_module.web_interface
  json.url @auth_token.url
end
