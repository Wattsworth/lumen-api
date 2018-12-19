Rails.application.configure do

  # display custom label in page header
  #
  config.node_name = "Donnal House"

  # enable password recovery and e-mail invitations
  # NOTE: configure smtp.rb with smtp server details
  #
  config.send_emails = true

end