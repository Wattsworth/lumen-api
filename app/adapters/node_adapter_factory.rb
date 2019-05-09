class NodeAdapterFactory
  include HTTParty
  default_timeout 5
  open_timeout 5
  read_timeout 5

  def self.from_nilm(nilm)
    if nilm.node_type=='nilmdb'
      return Nilmdb::Adapter.new(nilm.url)
    elsif nilm.node_type=='joule'
      return Joule::Adapter.new(nilm.url, nilm.key)
    end
    return nil
  end
end