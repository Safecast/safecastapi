# frozen_string_literal: true

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
      allow(controller).to receive(:system).and_return(system('true')) # Not to run cron jobs
    end

    describe 'when task exists' do
      before do
        request.headers['X-Aws-Sqsd-Taskname'] = 'dump_clean'
        get :create
      end

      it 'returns HTTP 200 OK' do
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'when task exists but try to run same job' do
      before do
        request.headers['X-Aws-Sqsd-Taskname'] = 'dump_measurements'
        get :create
      end

      it 'returns HTTP 403 Forbidden' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
