# frozen_string_literal: true

# frozen_string_literals: true

require 'spec_helper'

RSpec.describe CronsController do
  describe 'GET #create' do
    before do
      @request.env['REMOTE_ADDR'] = '127.0.0.1'
      allow(IO).to receive(:popen)
        .with('ps ax')
        .and_yield(
          StringIO.new(<<~STRING)
            PID TTY          TIME CMD
            1 ?        S      0:00 bash ./dump_measurements
          STRING
        )
      allow(controller).to receive(:system) # Not to run cron jobs
      allow($?).to receive(:success?).and_return(true) # rubocop:disable Style/SpecialGlobalVars
    end

    describe 'when task exists' do
      before do
        allow(controller).to receive(:taskname).and_return('dump_clean')
      end

      it 'returns HTTP 200 OK' do
        get :create

        expect(response).to have_http_status(200)
      end
    end

    describe 'when task exists but try to run same job' do
      before do
        allow(controller).to receive(:taskname).and_return('dump_measurements')
      end

      it 'returns HTTP 403 Forbidden' do
        get :create

        expect(response).to have_http_status(403)
      end
    end
  end
end
