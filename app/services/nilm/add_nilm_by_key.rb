# frozen_string_literal: true
require 'uri'
require 'resolv'

class AddNilmByKey
  include ServiceStatus
  attr_reader :nilm

  def run(request_params, remote_ip)


    required_keys =
        [:port, :scheme, :name, :api_key, :auth_key]


    joule_params = request_params.permit(required_keys+[:name_is_host])

    begin
      required_keys.each{|key| joule_params.require(key)}
    rescue ActionController::ParameterMissing => e
      add_error(e.message)
      return self
    end

    #1 Find the requestor
    auth_key = NilmAuthKey.find_by_key(joule_params[:auth_key])
    if auth_key.nil?
      add_error("invalid authorization key")
      return self
    end
    #2 Figure out the remote URL (resolve IP address to domain name for SSL)
    if joule_params[:name_is_host].nil?
      host = remote_ip
    else
      host = joule_params[:name]
    end
    url = URI("http://temp")
    url.host = host
    url.port = joule_params[:port]
    url.scheme = joule_params[:scheme]
    #3 Create the Nilm
    adapter = Joule::Adapter.new(url, joule_params[:api_key])
    service = CreateNilm.new(adapter)
    absorb_status(service.run(name: joule_params[:name], url:url,
                              key: joule_params[:api_key],
                              owner: auth_key.user))
    auth_key.destroy if service.success?
    @nilm = service.nilm
    self
  end
end
