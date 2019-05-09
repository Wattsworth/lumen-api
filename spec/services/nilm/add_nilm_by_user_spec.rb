# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'AddNilmByUser' do
  describe 'run' do
    it 'creates a user and an associated nilm' do
      service = AddNilmByUser.new
      user_params = {email: "bob@email.com", password: "password",
                     first_name: "Bob", last_name: "Test"}
      nilm_params = {name: "Test Node", api_key: "api_key", port: 8088, scheme: "http"}
      request_params = ActionController::Parameters.new(user_params.merge(nilm_params))

      service.run(request_params,"127.0.0.1")
      expect(service.success?).to be true
      # creates the nilm
      nilm = service.nilm
      expect(nilm.url).to eq "http://localhost:8088"
      expect(nilm.name).to eq "Test Node"
      expect(nilm.key).to eq "api_key"
      # creates the user associated with the nilm
      owner = User.find_by_email("bob@email.com")
      expect(owner.admins_nilm?(nilm)).to be true
      # forwards warnings (can't contact made up installation)
      expect(service.warnings?).to be true
    end
    it 'requires all parameters' do
      service = AddNilmByUser.new
      user_params = {password: "missing_email",
                     first_name: "Bob", last_name: "Test"}
      nilm_params = {name: "Test Node", api_key: "api_key", port: 8088, scheme: "http"}
      request_params = ActionController::Parameters.new(user_params.merge(nilm_params))
      service.run(request_params,"127.0.0.1")
      expect(service.success?).to be false
      u = User.new(user_params)
      u.valid?
      # forwards error messages
      expect(service.errors[0]).to match /email/
      # does not create the nilm
      expect(Nilm.count).to eq 0
    end
    it 'requires valid user parameters' do
      service = AddNilmByUser.new
      user_params = {email: "bob@email.com", password: "short",
                     first_name: "Bob", last_name: "Test"}
      nilm_params = {name: "Test Node", api_key: "api_key", port: 8088, scheme: "http"}
      request_params = ActionController::Parameters.new(user_params.merge(nilm_params))
      service.run(request_params,"127.0.0.1")
      expect(service.success?).to be false
      u = User.new(user_params)
      u.valid?
      # forwards error messages
      expect(service.errors).to eq(u.errors.full_messages)
      # does not create the nilm
      expect(Nilm.count).to eq 0
    end

    it 'forwards nilm errors' do
      nilm = create(:nilm)
      nilm.url = "http://localhost:8088"
      nilm.save!

      service = AddNilmByUser.new
      user_params = {email: "bob@email.com", password: "password",
                     first_name: "Bob", last_name: "Test"}
      nilm_params = {name: "Test Node", api_key: "api_key", port: 8088, scheme: "http"}
      request_params = ActionController::Parameters.new(user_params.merge(nilm_params))
      service.run(request_params,"127.0.0.1")

      # NILM already exists with the specified URL
      expect(service.success?).to be false
      # no new NILM created
      expect(Nilm.count).to eq 1
      # new user is not created
      expect(User.find_by_email("bob@email.com")).to be nil

    end


  end
end

