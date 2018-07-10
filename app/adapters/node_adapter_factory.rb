class NodeAdapterFactory
  include HTTParty

  def self.from_url(url)
    begin
      resp = self.class.get(url)
      return nil unless resp.success?
      info = resp.parsed_response
    rescue
      return nil
    end
    if info.include? 'NilmDB'
      return Nilmdb::Adapter(url)
    elsif info.include? 'Joule'
      return Joule::Adapter(url)
    else
      return nil
    end
  end

  def self.from_nilm(nilm)
    if nilm.type=='nilmdb'
      return Nilmdb::Adapter(nilm.url)
    elsif nilm.type=='joule'
      return Joule::Adapter(nilm.url)
    else
      # try to figure out what this nilm is
      return self.from_url(nilm.url)
    end
  end
end