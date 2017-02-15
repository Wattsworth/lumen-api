require 'rails_helper'

RSpec.describe UserGroup, type: :model do
  describe "UserGroup Behavior" do
    context "Given a group with four members" do
      before(:each) do
        #users
        @john = create(:user, first_name: "John")
        @nicky = create(:user, first_name: "Nicky")
        @pete = create(:user, first_name: "Pete")
        @leeb = create(:user, first_name: "Leeb")
        #groups
        @group = create(:user_group, name: "Group", owner: @john,
                        members: [@john, @nicky, @pete, @leeb])
      end
      it "has an owner and four members" do
        expect(@group.users.count).to eq(4)
        expect(@group.owner).to eq(@john)
        expect(@group.users).to eq([@john,@nicky,@pete,@leeb])
      end
    end
  end
end
