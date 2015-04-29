require 'rails_helper'

describe Group do
  describe "validations" do
    it { should  have_many(:genres) }
  end
end
