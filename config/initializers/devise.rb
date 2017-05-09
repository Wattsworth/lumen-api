Devise.setup do |config|
  # The e-mail address that mail will appear to be sent from
  # If absent, mail is sent from "please-change-me-at-config-initializers-devise@example.com"
  config.mailer_sender = "support@wattsworth.net"

  # If using rails-api, you may want to tell devise to not use ActionDispatch::Flash
  # middleware b/c rails-api does not include it.
  # See: http://stackoverflow.com/q/19600905/806956
  config.navigational_formats = [:json]

  # ==> Configuration for :invitable
  # The period the generated invitation token is valid, after
  # this period, the invited resource won't be able to accept the invitation.
  # When invite_for is 0 (the default), the invitation won't expire.
  # config.invite_for = 2.weeks
  # Number of invitations users can send.
  # - If invitation_limit is nil, there is no limit for invitations, users can
  # send unlimited invitations, invitation_limit column is not used.
  # - If invitation_limit is 0, users can't send invitations by default.
  # - If invitation_limit n > 0, users can send n invitations.
  # You can change invitation_limit column for some users so they can send more
  # or less invitations, even with global invitation_limit = 0
  # Default: nil
  # config.invitation_limit = 5
  # The key to be used to check existing users when sending an invitation
  # and the regexp used to test it when validate_on_invite is not set.
  # config.invite_key = {:email => /\\A[^@]+@[^@]+\\z/}
  # config.invite_key = {:email => /\\A[^@]+@[^@]+\\z/, :username => nil}
  # Flag that force a record to be valid before being actually invited
  # Default: false
  # config.validate_on_invite = true
  # Resend invitation if user with invited status is invited again
  # Default: true
  # config.resend_invitation = false
  # The class name of the inviting model. If this is nil,
  # the #invited_by association is declared to be polymorphic.
  # Default: nil
  # config.invited_by_class_name = 'User'
  # The foreign key to the inviting model (if invited_by_class_name is set)
  # Default: :invited_by_id
  # config.invited_by_foreign_key = :invited_by_id
  # The column name used for counter_cache column. If this is nil,
  # the #invited_by association is declared without counter_cache.
  # Default: nil
  # config.invited_by_counter_cache = :invitations_count
  # Auto-login after the user accepts the invite. If this is false,
  # the user will need to manually log in after accepting the invite.
  # Default: true
  # config.allow_insecure_sign_in_after_accept = false
end
