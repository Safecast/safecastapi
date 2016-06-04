require 'spec_helper'

RSpec.describe User, type: :model do
  let(:user) { Fabricate.build(:user, :name => "Paul Campbell")}
  
  describe "#first_name and #last_name" do
    subject { user }
    its(:first_name)  { should == 'Paul' }
    its(:last_name)   { should == 'Campbell' }
  end
end
