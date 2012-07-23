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

    it "should count the number of lines in the file" do
      bgeigie_import.lines_count.should == 23
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

    it "should calculate measurements to the correct hemisphere" do
      bgeigie_nyc = Fabricate(:bgeigie_import,
                              :source => File.new(Rails.root + 'spec/fixtures/bgeigie_nyc.log'),
                              :user => user)

      bgeigie_nyc.process
      bgeigie_nyc.finalize!

      measurement = Measurement.find_by_md5sum('c435ff4da6a7a16e92282bd10381b6d7')

      measurement.location.x.should == -73.92277166666666
      measurement.location.y.should == 41.69807833333333
    end


    it "should calculate measurements to the correct hemisphere" do
      bgeigie_with_bugs = Fabricate(:bgeigie_import,
                                    :source => File.new(Rails.root + 'spec/fixtures/bgeigie_with_tinygps_bug.log'),
                                    :user => user)

      bgeigie_with_bugs.process
      bgeigie_with_bugs.finalize!

      measurement = Measurement.find_by_md5sum('97badba59dda4a56958fc40b16277db4')

      measurement.location.x.should == -73.92259666666668
      measurement.location.y.should == 41.69836166666667
    end

    it "should handle files with corrupt or incomplete lines" do
      bgeigie_with_bugs = Fabricate(:bgeigie_import,
                                    :source => File.new(Rails.root + 'spec/fixtures/bgeigie_with_corruption.log'),
                                    :user => user)

      bgeigie_with_bugs.process
      bgeigie_with_bugs.finalize!

      Measurement.all.count.should == 30 #the before :each import has 23, and the corrupted file should have 7 valid measurements

    end
    
  end
  
  after(:each) { BgeigieLog.destroy_all }
end
