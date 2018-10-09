require 'factory_bot_rails'

ADMIN_NAME="admin"
ADMIN_PASSWORD ="password"
ADMIN_EMAIL    ="admin@wattsworth.localhost"



namespace :local do
  desc "Setup and standalone systems running Lumen API"
  task :bootstrap => :environment do


    # Create an admin user"
    @admin = User.find_by_email(ADMIN_EMAIL)

    if @admin.nil?
      puts 'Creating new admin user'
      @admin = FactoryBot.create(:user,
                      first_name: 'John',
                      last_name: 'Doe',
                      password: ADMIN_PASSWORD,
                      password_confirmation: ADMIN_PASSWORD,
                      email: ADMIN_EMAIL)
    end
    @installation = Nilm.find_by_url("http://localhost:8088")
    if @installation.nil?
      puts 'Creating new local installation'
      #create a local installation
      @node_adapter = Joule::Adapter.new("http://localhost:8088")
      nilm_creator = CreateNilm.new(@node_adapter)
      nilm_creator.run(
        name: 'local',
        description: 'local database',
        url: 'http://localhost:8088',
        owner: @admin
      )
    end
  end
end
