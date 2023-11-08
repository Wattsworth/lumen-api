module VerifyUrl

  def verify_url(orig_url, key)
    url = orig_url.dup
    begin
      resp = HTTParty.get(url, verify: false,
                          headers: {'X-API-KEY': key})
      if resp.parsed_response.downcase == 'joule server'
        return orig_url # orig url works, no need to change it
      end
    rescue StandardError # ignore exceptions
    end
    # orig_url doesn't work, check to see if the Docker IP address works instead
    url.host='172.17.0.1'
    begin
      resp = HTTParty.get(url, verify: false,
                          headers: {'X-API-KEY': key})
      # successful modification, return the new url
      return url if resp.parsed_response.downcase == 'joule server'
    rescue StandardError #ignore exceptions
    end
    nil # url is not valid and cannot be successfully modified
  end
end