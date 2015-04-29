require 'rails_helper'

describe Genre do
  describe "validations" do
    it { should  have_many(:playlists) }
    it { should  have_many(:styles) }
    it { should  belong_to(:group) }
  end
end
