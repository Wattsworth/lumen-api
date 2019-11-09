# frozen_string_literal: true
require 'uri'
require 'resolv'

class AddNilmByUser
  include ServiceStatus
  attr_reader :nilm

  def run(request_params, remote_ip)
    # Request Params is a hash with the following keys:
    # User: [first_name, last_name, email, password]
    # Nilm: [port, scheme, name, api_key]

    #0 make  sure parameters are present

    required_keys =
        [:port, :scheme, :name, :api_key] +
        [:first_name, :last_name, :email, :password]

    request_params = request_params.permit(required_keys+[:name_is_host, :base_uri])
    # since we're not explicitly checking for base_uri, give it a default value
    # it should always be present but may be "" which causes the require action to fail
    request_params[:base_uri]="" if request_params[:base_uri].nil?

    begin
      required_keys.each{|key| request_params.require(key)}
    rescue ActionController::ParameterMissing => e
      add_error(e.message)
      return self
    end

    #1 Create a new user
    owner = User.new(request_params.slice(:first_name, :last_name, :email, :password))
    unless owner.save
      add_errors(owner.errors.full_messages)
      return self
    end
    #2 Figure out the remote URL (resolve IP address to domain name for SSL)
    if request_params[:name_is_host].nil?
      host = remote_ip
    else
      host = request_params[:name]
    end
    url = URI("http://temp")
    url.host = host
    url.port = request_params[:port]
    url.scheme = request_params[:scheme]
    url.path = request_params[:base_uri]
    #3 Create the Nilm
    adapter = Joule::Adapter.new(url, request_params[:api_key])
    service = CreateNilm.new(adapter)
    absorb_status(service.run(name: request_params[:name], url:url,
                              key: request_params[:api_key],
                              owner: owner))
    # remove the user if the NILM couldn't be created
    owner.destroy if service.errors?
    @nilm = service.nilm
    self
  end
end
