# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'bgeigie_imports/_auto_approve_status.html.erb', type: :view do
  context 'Zero CPM Status' do
    let(:bgeigie_import) { Fabricate(:bgeigie_import, auto_apprv_no_zero_cpm: auto_apprv_no_zero_cpm) }

    before do
      assign(:bgeigie_import, bgeigie_import)

      render
    end

    subject { Nokogiri.HTML(rendered).xpath('//li[2]/i').first['class'].split }

    context 'No zero CPM' do
      let(:auto_apprv_no_zero_cpm) { true }

      it { is_expected.to include('icon-ok') }
    end

    context 'No zero CPM' do
      let(:auto_apprv_no_zero_cpm) { false }

      it { is_expected.to include('icon-remove') }
    end
  end
end
