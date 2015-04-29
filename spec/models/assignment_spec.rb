require 'rails_helper'

describe Assignment do
  describe "validations" do
    it { should  belong_to(:playlist) }
    it { should  belong_to(:track) }
  end
end
