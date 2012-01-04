require 'spec_helper'

describe BgeigieImport do
  
  let!(:user) { User.first || Fabricate(:user) }
  
  let!(:bgeigie_import) do
    Fabricate(:bgeigie_import,
              :source => File.new(Rails.root + 'spec/fixtures/bgeigie.log'),
              :user_id => user.id
             )
  end
  
  describe "#process" do
    before(:each) do
      bgeigie_import.process
    end

    it "should create 23 Bgeigie Logs" do
      BgeigieLog.count.should == 23
    end
    
    it "should set the id" do
      BgeigieLog.all.collect { |bl| bl.bgeigie_import_id }.uniq.should == [bgeigie_import.id]
    end
    
    it "should create measurements" do
      Measurement.count.should == 23
    end
    
  end
  
  after(:each) { BgeigieLog.destroy_all }
end