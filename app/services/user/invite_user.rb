# frozen_string_literal: true

# Invite new users by e-mail
class InviteUser
  include ServiceStatus
  attr_reader :user

  def run(inviter, email, redirect_url)
    # create a new user account for [email]
    # if an account with [email] exists and is confirmed
    # add a warning that the user exists
    # if the account exists but is not confirmed send another email
    # and add a success message that the e-mail was sent
    #
    @user = User.find_by_email(email)
    if @user.nil? || !@user.accepted_or_not_invited?
      #invite the user, they are new or have not accepted their invitation
      @user = User.invite!({:email=>email}, inviter) do |u|
        u.invitation_url = redirect_url
      end
      unless @user.errors.empty?
        add_errors(@user.errors.full_messages)
        return self
      end
      set_notice("sent invitation to [#{email}]")
    else
      # user exists already
      add_warning("account exists for #{email}")
      return self
    end
    self
  end
end
