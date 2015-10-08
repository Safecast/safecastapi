require 'spec_helper'

describe AirImport do
  let!(:user) { User.first || Fabricate(:user) }

  let!(:air_import) do
    Fabricate(:air_import,
              :source => File.new(Rails.root.join('spec/fixtures/air0simple.log')),
              :user_id => user.id
    )
  end

  let(:lines)        { 1 }
  let(:measurements) { 53 }

  before(:each) do
    create_air_v0_station
  end

  describe "#process" do
    before(:each) do
      air_import.process
    end

    it "should create air logs with populated values" do
      air_import.air_logs.count.should == lines * measurements
      air_import.air_logs.map(&:measurement).should == [
        # gas array 1
        0.27, 0.26, 27.86, 26.98,
        0.36, 0.35, 15.81, 11.76,
        0.63, 0.32, 633.26, 623.23,

        # gas array 2
        0.28, 0.27, 11.2, 21.92,
        0.39, 0.38, 73.72, 58.28,
        0.63, 0.35, 617.96, 605.38,

        # temp
        23.89, 23.45,
        23.8, 23.22,

        # particle
        0.0, 0.0, 0.0, 3.7, 60.13, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
      ]

      # only testing units for gas, since logic is the same for all
      air_import.air_logs[0..3].map(&:unit).should        == %w(volts volts ppb ppb)

      # only testing gps for first, since gps is only assembled once then copied
      sample_log = air_import.air_logs.first
      sample_log.captured_at.should     == Time.parse("2015-09-24T21:58:54Z")
      sample_log.latitude.round.should  == 34
      sample_log.longitude.round.should == -118
      sample_log.altitude.round.should  == 128
    end

    it "should count the number of lines in the file" do
      air_import.lines_count.should == lines
    end
  end

  describe "#finalize!" do
    before(:each) do
      air_import.process
      air_import.finalize!
    end

    it "should create measurements" do
      Measurement.count.should == lines * measurements
    end
  end
end