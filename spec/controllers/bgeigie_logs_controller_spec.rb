# frozen_string_literal: true

RSpec.describe BgeigieLogsController, type: :controller do
  let!(:bgeigie_import) { Fabricate(:bgeigie_import) }

  describe 'GET #index', format: :json do
    before do
      get :index, params: { bgeigie_import_id: bgeigie_import.id, format: :json }
    end

    it { expect(response).to be_ok }
  end
end
