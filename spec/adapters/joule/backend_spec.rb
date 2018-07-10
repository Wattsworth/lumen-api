# frozen_string_literal: true

require 'rails_helper'

describe Joule::Backend do
  # use the benchtop server joule API
  let (:url) {'http://172.16.1.12/joule'}
  it 'retrieves module infos', :vcr do
    backend = Joule::Backend.new(url)
    backend.module_info.each do |m|
      expect(m).to include(:name, :exec_cmd, :web_interface)
    end
  end
end
