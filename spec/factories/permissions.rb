FactoryBot.define do
  factory :permission do
    nilm
    role "admin"
    after(:build) do |permission|
      # if no user or group specified, create a user
      if(permission.user.blank? &&
        permission.user_group.blank?)
        permission.user = create(:user)
      end
    end
  end

end
