# Be sure to restart your server when you modify this file.

Rails.application.config.filter_parameters += [:password]
Rails.application.config.filter_parameters << lambda do |key, value|
  value.replace('[BASE64 STRING OMITTED]') if key == 'redux_json' || key == 'image'
end

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]
