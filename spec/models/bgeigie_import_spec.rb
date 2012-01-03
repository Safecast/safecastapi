require 'spec_helper'

describe BgeigieImport do
  let!(:bgeigie_import) do
    Fabricate(:bgeigie_import,
              :source => File.new(Rails.root + 'spec/fixtures/bgeigie.log')
             )
  end
  
  describe "#process" do
    before(:all) do
      bgeigie_import.process
    end

    it "should create 23 Bgeigie Logs" do
      BgeigieLog.count.should == 23
    end
    
    it "should set the id" do
      BgeigieLog.all.collect { |bl| bl.bgeigie_import_id }.uniq.should == [bgeigie_import.id]
    end
    
  end
  
  after(:all) { BgeigieLog.destroy_all }
end