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
  let(:measurements) { 4 }

  before(:each) do
    air_station = Station.new(id: 1)
    air_unit = air_station.device_units.build(id: 1)
    air_group = air_unit.device_groups.build(id: 1)

    co_2 = {manufacturer: "Alphasense", model: "CO2-D1"}
    air_group.devices.build(co_2.merge(id: 1, unit: "volts", sensor: "working electrode voltage"))
    air_group.devices.build(co_2.merge(id: 2, unit: "volts", sensor: "auxiliary electrode voltage"))
    air_group.devices.build(co_2.merge(id: 3, unit: "ppb",   sensor: "gas concentration"))
    air_group.devices.build(co_2.merge(id: 4, unit: "ppb",   sensor: "gas concentration, lowpass filtered"))
    air_station.save!
    air_station
  end

  describe "#process" do
    before(:each) do
      air_import.process
    end

    it "should create air logs with individual values" do
      air_import.air_logs.count.should == lines * measurements
      air_import.air_logs.map(&:measurement).should == [0.27, 0.26, 27.86, 26.98]
      air_import.air_logs.map(&:unit).should        == %w(volts volts ppb ppb)
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