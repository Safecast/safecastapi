# frozen_string_literal: true

RSpec.describe BgeigieImports::AutoApprovedController, type: :controller do
  describe 'GET #index' do
    context 'when logging in as administrator' do
      before do
        sign_in Fabricate(:admin_user)

        get :index
      end

      it { expect(response).to be_ok }
      # Cannot use .to be_present because AR::Relation that is empty
      # returns true to #blank?
      it { expect(assigns(:bgeigie_imports)).to_not be_nil }
    end

    context 'when logging in as normal user' do
      before do
        sign_in Fabricate(:user)

        get :index
      end

      it 'has flash message' do
        expect(flash[:alert]).to eq('access_denied')
      end
    end
  end
end
