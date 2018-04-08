# frozen_string_literal: true

require 'rails_helper'

describe JouleAdapter do
  # use the benchtop server joule API
  let (:url) {'http://172.16.1.12/joule'}
  it 'retrieves module infos', :vcr do
    adapter = JouleAdapter.new(url)
    adapter.module_info.each do |m|
      expect(m).to include(:name, :exec_cmd, :web_interface)
    end
  end
end
