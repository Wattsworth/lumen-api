# frozen_string_literal: true
require 'uri'
require 'resolv'

class AddNilmByKey
  include ServiceStatus
  include VerifyUrl
  attr_reader :nilm

  def run(request_params, remote_ip)


    required_keys =
        [:port, :scheme, :name, :api_key, :auth_key]
    # sanitize parameters so the next line doesn't raise an exception:
    request_params.slice!(*required_keys+[:name_is_host, :base_uri, :return_address])
    joule_params = request_params.permit(required_keys+[:name_is_host, :base_uri, :return_address])
    # since we're not explicitly checking for base_uri, give it a default value
    # it should always be present but may be "" which causes the require action to fail
    joule_params[:base_uri]="" if joule_params[:base_uri].nil?

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
    auth_key.destroy
    #2 Figure out the Joule URL if it is not specified
    # (resolve IP address to domain name for SSL)
    if joule_params.has_key?('return_address')
      url = URI(joule_params[:return_address])
    else
      if joule_params[:name_is_host].nil?
        host = remote_ip
      else
        host = joule_params[:name]
      end
      url = URI("http://temp")
      url.host = host
      url.port = joule_params[:port]
      url.scheme = joule_params[:scheme]
      url.path = joule_params[:base_uri]
    end
    #2 Check to see if the URL works
    verified_url = verify_url(url,request_params[:api_key])
    url = verified_url unless verified_url.nil?
    #3 Create the Nilm
    adapter = Joule::Adapter.new(url, joule_params[:api_key])
    service = CreateNilm.new(adapter)
    absorb_status(service.run(name: joule_params[:name], url:url,
                              key: joule_params[:api_key],
                              owner: auth_key.user))
    @nilm = service.nilm
    self
  end
end
