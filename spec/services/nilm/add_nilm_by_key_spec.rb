# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'AddNilmByKey' do
  describe 'run' do
    it 'creates nilm owned by the specified user' do
      owner = create(:user)
      key = NilmAuthKey.new(key: "random_key", user: owner)
      key.save!

      user_params = {auth_key: "random_key"}
      nilm_params = {name: "Test Node", api_key: "api_key", port: 8088, scheme: "http"}
      request_params = ActionController::Parameters.new(user_params.merge(nilm_params))

      service = AddNilmByKey.new
      service.run(request_params,"127.0.0.1")
      expect(service.success?).to be true
      # creates the nilm
      nilm = service.nilm
      expect(nilm.url).to eq "http://127.0.0.1:8088"
      expect(nilm.name).to eq "Test Node"
      expect(nilm.key).to eq "api_key"
      # owner is an admin for the nilm
      expect(owner.admins_nilm?(nilm)).to be true
      # forwards warnings (can't contact made up installation)
      expect(service.warnings?).to be true
      # destroys the auth key
      expect(NilmAuthKey.count).to eq 0
    end

    it 'requires valid auth key' do
      service = AddNilmByKey.new
      user_params = {auth_key: "invalid"}
      nilm_params = {name: "Test Node", api_key: "api_key", port: 8088, scheme: "http"}
      request_params = ActionController::Parameters.new(user_params.merge(nilm_params))
      service.run(request_params,"127.0.0.1")
      expect(service.success?).to be false
      # forwards error messages
      expect(service.errors[0]).to match("invalid authorization key")
      # does not create the nilm
      expect(Nilm.count).to eq 0
    end

    it 'forwards nilm errors' do
      nilm = create(:nilm)
      nilm.url = "http://127.0.0.1:8088"
      nilm.save!
      owner = create(:user)
      key = NilmAuthKey.new(key: "random_key", user: owner)
      key.save!

      user_params = {auth_key: "random_key"}
      nilm_params = {name: "Test Node", api_key: "api_key", port: 8088, scheme: "http"}
      request_params = ActionController::Parameters.new(user_params.merge(nilm_params))

      service = AddNilmByKey.new
      service.run(request_params,"127.0.0.1")
      # NILM already exists with the specified URL
      expect(service.success?).to be false
      # no new NILM created
      expect(Nilm.count).to eq 1
      # owner doesn't get permissions on the existing nilm
      expect(owner.admins_nilm?(nilm)).to be false
      # auth key is not deleted
      expect(NilmAuthKey.count).to eq 1
    end

  end
end

