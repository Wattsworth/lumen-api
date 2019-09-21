# frozen_string_literal: true

require 'rails_helper'

describe 'InviteUser service' do
  let(:inviter) { create(:user) }
  let(:service) { InviteUser.new }
  describe 'when email is not in database' do
    before do
      service.run(inviter,"test@test.com","http://redirect.url")
      @invitee = service.user
    end
    it 'creates a new user' do
      expect(@invitee).to be_invited_to_sign_up
      expect(@invitee.invited_by).to eq inviter
    end
    it 'returns error on invalid parameters' do
      service.run(inviter,"","http://redirect.url")
      expect(service.errors?).to be true

    end
    it 'sends the user an invitation' do
      invitation = ActionMailer::Base.deliveries.last
      expect(invitation.to).to eq [@invitee.email]
      expect(invitation.body.encoded).to include @invitee.raw_invitation_token
    end
    it 'adds notice message' do
      expect(service.errors?).to be false
      expect(service.warnings?).to be false
      expect(service.notices.length).to eq 1
    end
  end
  describe 'when email in database' do
    before do
      service.run(inviter,"test@test.com","http://redirect.url")
      @invitee = service.user
    end
    it 'does not create a new user' do
      #invite again
      service.run(inviter,"test@test.com","http://redirect.url")
      expect(service.user).to eq @invitee
    end
    it 'does not send an invitation if the user has already accepted' do
      User.accept_invitation!(
        invitation_token: @invitee.raw_invitation_token,
        password: "ad97nwj3o2", first_name: "John Doe", last_name: "Doe")
      email_count = ActionMailer::Base.deliveries.length
      service.run(inviter,"test@test.com","http://redirect.url")
      expect(ActionMailer::Base.deliveries.length).to eq email_count
      expect(service.warnings.length).to eq 1
    end
    it 'resends invitation if user has not accepted yet' do
      email_count = ActionMailer::Base.deliveries.length
      service.run(inviter,"test@test.com","http://redirect.url")
      expect(ActionMailer::Base.deliveries.length).to eq email_count+1
      expect(service.notices.length).to eq 1
    end
  end

end
