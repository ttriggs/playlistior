require 'rails_helper'

describe Follow do
  describe "validations" do
    it { should  belong_to(:playlist) }
    it { should  belong_to(:user) }

    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:playlist_id) }
  end
end
