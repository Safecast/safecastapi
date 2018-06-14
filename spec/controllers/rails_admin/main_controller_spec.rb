# XXX: Currently, this spec is for checking rails_admin gem installation.
RSpec.describe RailsAdmin::MainController, 'login as admin', type: :controller do
  routes { RailsAdmin::Engine.routes }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]

    sign_in Fabricate(:admin_user)
  end

  let!(:bgeigie_log) { BgeigieLog.create }
  let(:model_name) { 'bgeigie_log' }

  describe 'GET #dashboard' do
    before do
      get :dashboard
    end

    it { expect(response).to be_ok }
  end

  describe 'GET #index' do
    before do
      get :index, model_name: model_name
    end

    it { expect(response).to be_ok }
  end

  describe 'POST #index' do
    before do
      post :index, model_name: model_name
    end

    it { expect(response).to be_ok }
  end

  describe 'GET #new' do
    before do
      get :new, model_name: model_name
    end

    it { expect(response).to be_ok }
  end

  describe 'POST #new' do
    before do
      get :new, model_name: model_name
    end

    it { expect(response).to be_ok }
  end

  describe 'GET #show' do
    before do
      get :show, id: bgeigie_log.id, model_name: model_name
    end

    it { expect(response).to be_ok }
  end
end

RSpec.describe RailsAdmin::MainController, 'login as user', type: :controller do
  routes { RailsAdmin::Engine.routes }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]

    sign_in Fabricate(:user)
  end

  let!(:bgeigie_log) { BgeigieLog.create }
  let(:model_name) { 'bgeigie_log' }

  describe 'GET #dashboard' do
    before do
      get :dashboard
    end

    it { expect(response).to redirect_to('/') }
  end
end
