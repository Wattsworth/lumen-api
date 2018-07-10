class NodeAdapterFactory
  include HTTParty
  default_timeout 5
  open_timeout 5
  read_timeout 5

  def self.from_url(url)
    begin
      resp = get(url)
      return nil unless resp.success?
      info = resp.parsed_response
    rescue
      return nil
    end
    if info.include? 'NilmDB'
      return Nilmdb::Adapter.new(url)
    elsif info.include? 'Joule'
      return Joule::Adapter.new(url)
    else
      return nil
    end
  end

  def self.from_nilm(nilm)
    if nilm.node_type=='nilmdb'
      return Nilmdb::Adapter.new(nilm.url)
    elsif nilm.node_type=='joule'
      return Joule::Adapter.new(nilm.url)
    else
      # try to figure out what this nilm is
      return self.from_url(nilm.url)
    end
  end
end