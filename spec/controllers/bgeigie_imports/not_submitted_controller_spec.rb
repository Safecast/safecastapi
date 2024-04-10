# frozen_string_literal: true

RSpec.describe BgeigieImports::NotSubmittedController do
  before do
    sign_in Fabricate(:admin_user)
  end

  describe 'GET #index' do
    before do
      get :index
    end

    it { expect(response).to be_ok }
    # Cannot use .to be_present because AR::Relation that is empty
    # returns true to #blank?
    it { expect(assigns(:bgeigie_imports)).to_not be_nil }
  end
end
