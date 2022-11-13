# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'bgeigie_imports/show.html.erb', type: :view do
  before do
    controller.default_url_options[:locale] = 'en-US'
    stub_template('layouts/_current_page_api_example.html.erb' => '')
  end

  after do
    controller.default_url_options[:locale] = nil
  end

  context 'When BgeigieImport status is awaiting_response' do
    before do
      assign(:bgeigie_import, bgeigie_import)
      params[:id] = bgeigie_import.id
    end

    context 'with no contact history' do
      let(:bgeigie_import) { Fabricate(:bgeigie_import, status: 'awaiting_response') }

      it '例外が発生しない' do
        expect { render }.not_to raise_error
      end
    end
  end
end
