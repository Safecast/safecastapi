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
      bgeigie_import.finalize!
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
    
    it "should not load them twice" do
      bgeigie_import.process
      Measurement.count.should == 23
    end
    
    it "should add measurements to the map" do
      bgeigie_import.reload.map.should have(23).measurements
    end
    
    it "should set measurement attributes" do
      measurement = Measurement.find_by_md5sum('6750a7cf2a630c2dde416dc7d138fa74')
      measurement.location.should_not be_blank
      measurement.captured_at.should_not be_blank
    end
    
  end
  
  after(:each) { BgeigieLog.destroy_all }
end