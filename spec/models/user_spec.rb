require 'spec_helper'

describe User do
  let(:user) { Fabricate.build(:user, :name => "Paul Campbell")}
  
  describe "#first_name and #last_name" do
    subject { user }
    its(:first_name) { should == 'Paul' }
    its(:last_name) { should == 'Campbell' }
  end
end