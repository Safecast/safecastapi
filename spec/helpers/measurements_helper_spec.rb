# frozen_string_literal: true

RSpec.describe MeasurementsHelper, type: :helper do
  describe '#measurement_nav_li' do
    before do
      allow(helper).to receive(:[]).with(:unit).and_return('all')
    end

    it 'should have li tag with "active" class attribute' do
      doc = Nokogiri.HTML(helper.measurement_nav_li(:all))

      expect(doc.xpath("//li[@class='active']")).to be_present
    end
  end
end
