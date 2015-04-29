require 'rails_helper'

describe Style do
  describe "validations" do
    it { should  belong_to(:playlist) }
    it { should  belong_to(:genre) }
  end
end
