# frozen_string_literal: true

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      respond_to do |format|
        format.html { render plain: 'html' }
        format.json { render plain: 'json' }
      end
    end
  end

  describe 'force_ssl' do
    around do |example|
      original_env = Rails.env
      Rails.env = 'production'
      example.run
      Rails.env = original_env
    end

    context 'http access' do
      before do
        request.host = 'api-specs.safecast.org'
        get :index, params: { format: format }
      end

      context 'html format' do
        let(:format) { :html }

        it { expect(response.status).to eq 301 }
        it { expect(response.headers['Strict-Transport-Security']).to be_blank }
      end

      context 'json format' do
        let(:format) { :json }

        it { expect(response.status).to eq 200 }
        it { expect(response.headers['Strict-Transport-Security']).to be_blank }
      end
    end

    context 'https access' do
      before do
        request.headers['HTTPS'] = 'on'
        get :index, params: { format: format }
      end

      context 'html format' do
        let(:format) { :html }

        it { expect(response.status).to eq 200 }
        it { expect(response.headers['Strict-Transport-Security']).to be_present }
      end

      context 'json format' do
        let(:format) { :json }

        it { expect(response.status).to eq 200 }
        it { expect(response.headers['Strict-Transport-Security']).to be_present }
      end
    end
  end
end
