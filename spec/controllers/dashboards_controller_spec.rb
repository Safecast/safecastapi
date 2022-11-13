# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DashboardsController do
  describe 'GET #show' do
    before { get :show }

    context 'when user is not logged in' do
      it { is_expected.to render_template('home/show') }
    end
  end
end
