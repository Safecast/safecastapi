require 'spec_helper'

RSpec.describe BgeigieImport, type: :model do
  
  let!(:user) { User.first || Fabricate(:user) }
  
  let!(:bgeigie_import) do
    Fabricate(:bgeigie_import,
              :source => File.new(Rails.root.join('spec/fixtures/bgeigie.log')),
              :user_id => user.id
             )
  end
  
  describe "#process" do
    before(:each) do
      bgeigie_import.process
      bgeigie_import.finalize!
    end

    it "should create 23 Bgeigie Logs" do
      expect(BgeigieLog.count).to eq(23)
    end

    it "should count the number of lines in the file" do
      expect(bgeigie_import.lines_count).to eq(23)
    end
    
    it "should set the id" do
      expect(BgeigieLog.all.collect { |bl| bl.bgeigie_import_id }.uniq).to eq([bgeigie_import.id])
    end
    
    it "should create measurements" do
      expect(Measurement.count).to eq(23)
    end
    
    it "should not load them twice" do
      bgeigie_import.process
      expect(Measurement.count).to eq(23)
    end
    
    it "should set measurement attributes" do
      measurement = Measurement.find_by_md5sum('6750a7cf2a630c2dde416dc7d138fa74')
      expect(measurement.location).not_to be_blank
      expect(measurement.captured_at).not_to be_blank
    end

    it "should calculate measurements to the correct hemisphere" do
      bgeigie_nyc = Fabricate(:bgeigie_import,
                              :source => File.new(Rails.root + 'spec/fixtures/bgeigie_nyc.log'),
                              :user => user)

      bgeigie_nyc.process
      bgeigie_nyc.finalize!

      measurement = Measurement.find_by_md5sum('c435ff4da6a7a16e92282bd10381b6d7')

      expect(measurement.location.x).to eq(-73.92277166666666)
      expect(measurement.location.y).to eq(41.698078333333335)
    end


    it "should calculate measurements to the correct hemisphere" do
      bgeigie_with_bugs = Fabricate(:bgeigie_import,
                                    :source => File.new(Rails.root + 'spec/fixtures/bgeigie_with_tinygps_bug.log'),
                                    :user => user)

      bgeigie_with_bugs.process
      bgeigie_with_bugs.finalize!

      measurement = Measurement.find_by_md5sum('97badba59dda4a56958fc40b16277db4')

      expect(measurement.location.x).to eq(-73.92259666666666)
      expect(measurement.location.y).to eq(41.69836166666666)
    end

    it "should handle files with corrupt or incomplete lines" do
      bgeigie_with_bugs = Fabricate(:bgeigie_import,
                                    :source => File.new(Rails.root + 'spec/fixtures/bgeigie_with_corruption.log'),
                                    :user => user)

      bgeigie_with_bugs.process
      bgeigie_with_bugs.finalize!

      expect(Measurement.all.count).to eq(30) #the before :each import has 23, and the corrupted file should have 7 valid measurements

    end
    
  end
  
  after(:each) { BgeigieLog.destroy_all }
end
