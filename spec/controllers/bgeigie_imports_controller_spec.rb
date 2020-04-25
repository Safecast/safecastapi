# frozen_string_literal: true

RSpec.describe BgeigieImportsController, type: :controller do
  let(:user) { Fabricate(:user) }
  let(:administrator) { Fabricate(:admin_user) }

  describe 'GET #index', format: :json do
    let(:args) { { cities: 'Tokyo', credits: 'John Doe' } }

    before do
      %w(None Drive Surface Cosmic).each do |type|
        Fabricate(:bgeigie_import, args.merge(subtype: type))
      end
    end

    subject(:bgeigie_imports) { assigns(:bgeigie_imports) }

    context 'no filter' do
      before do
        get :index, params: { format: :json }
      end

      it 'should get all imports' do
        expect(bgeigie_imports.size).to eq(4)
      end
    end

    context 'subtype=Cosmic' do
      before do
        get :index, params: { subtype: 'Cosmic', format: :json }
      end

      it 'should filter by subtype' do
        expect(bgeigie_imports.size).to eq(1)
      end
    end

    context 'subtype=Drive,None' do
      before do
        get :index, params: { subtype: 'Drive,None', format: :json }
      end

      it 'should filter by subtype' do
        expect(bgeigie_imports.size).to eq(2)
      end
    end

    context 'status scope' do
      before do
        [
          { approved: true, approved_by: 'approver' },
          { rejected: true, rejected_by: 'rejector' }
        ].each do |opts|
          Fabricate(:bgeigie_import, args.merge(opts))
        end

        get :index, params: { status: status }
      end

      context 'approved' do
        let(:status) { 'approved' }

        it 'should list only approved imports' do
          expect(subject).to be_all(&:approved)
        end
      end

      context 'rejected' do
        let(:status) { 'rejected' }

        it 'should list only rejected imports' do
          expect(subject).to be_all(&:rejected)
        end
      end

      context 'not_moderated' do
        let(:status) { 'not_moderated' }

        it 'should list only imports that have not been moderated' do
          expect(subject).to be_none(&:approved)
            .and be_none(&:rejected)
        end
      end

      context 'invalid' do
        let(:status) { 'invalid' }

        it 'should list all imports' do
          expect(subject.size).to eq(6)
        end
      end
    end
  end

  describe 'POST #create', format: :json do
    let(:bgeigie_import_params) do
      {
        source: fixture_file_upload('/bgeigie.log'),
        cities: 'Tokyo',
        credits: 'John Doe'
      }
    end

    before do
      sign_in user

      post :create, params: { format: :json }.merge(post_params)
    end

    context 'without subtype' do
      let(:post_params) { { bgeigie_import: bgeigie_import_params } }

      it { expect(response.status).to eq(201) }
      it { expect(assigns(:bgeigie_import)).to be_persisted }
      it 'should set subtype of import to "None"' do
        expect(assigns(:bgeigie_import).subtype).to eq('None')
      end
    end

    context 'with subtype "Drive"' do
      let(:post_params) do
        { bgeigie_import: bgeigie_import_params.merge(subtype: 'Drive') }
      end

      it { expect(response.status).to eq(201) }
      it { expect(assigns(:bgeigie_import)).to be_persisted }
      it 'should set subtype of import to "None"' do
        expect(assigns(:bgeigie_import).subtype).to eq('Drive')
      end
    end

    context 'with empty subtype' do
      let(:post_params) do
        { bgeigie_import: bgeigie_import_params.merge(subtype: '') }
      end

      it { expect(response.status).to eq(201) }
      it { expect(assigns(:bgeigie_import)).to be_persisted }
      it 'should set subtype of import to "None"' do
        expect(assigns(:bgeigie_import).subtype).to eq('None')
      end
    end
  end

  describe 'DELETE #destroy', format: :html do
    before do
      sign_in login_user if login_user

      delete :destroy, params: { id: bgeigie_import.id }
    end

    context 'when bGeigie import is not approved' do
      let(:bgeigie_import) { Fabricate(:bgeigie_import, user: user, cities: 'Tokyo', credits: 'John Doe') }

      context 'when login user is owner of bgeigie import' do
        let(:login_user) { user }

        it { expect(response).to redirect_to(bgeigie_imports_path) }
        it 'should delete bgeigie import' do
          expect { BgeigieImport.find(bgeigie_import.id) }
            .to raise_exception(ActiveRecord::RecordNotFound)
        end
      end

      context 'when login user is not owner of bgeigie import' do
        let(:login_user) { Fabricate(:user) }

        it { expect(response).to be_not_found }
        it 'should not delete bgeigie import' do
          expect { BgeigieImport.find(bgeigie_import.id) }.to_not raise_error
        end
      end

      context 'when login user is not owner of bgeigie import, but moderator' do
        let(:login_user) { Fabricate(:user, moderator: true) }

        it { expect(response).to redirect_to(bgeigie_imports_path) }
        it 'should delete bgeigie import' do
          expect { BgeigieImport.find(bgeigie_import.id) }
            .to raise_exception(ActiveRecord::RecordNotFound)
        end
      end

      context 'when non-login user' do
        let(:login_user) { nil }

        # TODO: Switch back to new_user_session_path once we get locale out of the URL
        it { expect(response).to redirect_to(%r{users/sign_in}) }
        it 'should not delete bgeigie import' do
          expect { BgeigieImport.find(bgeigie_import.id) }.to_not raise_error
        end
      end
    end

    context 'when bGeigie import is approved' do
      let(:bgeigie_import) { Fabricate(:bgeigie_import, user: user, cities: 'Tokyo', credits: 'John Doe', approved: true) }

      context 'when login user is owner of bgeigie import' do
        let(:login_user) { user }

        it { expect(response).to redirect_to(bgeigie_imports_path) }
        it 'should delete not bgeigie import' do
          expect { BgeigieImport.find(bgeigie_import.id) }.not_to raise_error
        end
      end
    end
  end

  describe 'PATCH #approve' do
    let(:bgeigie_import) do
      Fabricate(:bgeigie_import, cities: 'Tokyo', credits: 'John Doe')
    end

    context 'non-login user' do
      before do
        patch :approve, params: { id: bgeigie_import.id }
      end

      it { expect(response).to redirect_to(root_path) }
      it { expect(flash[:alert]).to be_present }
    end
  end

  describe 'GET #kml' do
    let(:bgeigie_import) do
      Fabricate(:bgeigie_import, cities: 'Tokyo', credits: 'John Doe')
    end

    before do
      get :kml, params: { id: bgeigie_import.id }
    end

    it { expect(response).to be_ok }
    it { expect(response.content_type).to eq(Mime::Type.lookup("kml").to_s) }
    it 'should use original filename' do
      disposition = response.headers['Content-Disposition']
      expect(disposition)
        .to match(/#{bgeigie_import.source.filename}\.kml/)
    end
  end

  # iOS will use PUT method to update bgeigie import
  describe 'PUT #submit' do
    let!(:moderator) { Fabricate(:admin_user) }
    let(:bgeigie_import) { Fabricate(:bgeigie_import, user: user, cities: 'Tokyo', credits: 'John Doe') }

    before do
      ActionMailer::Base.deliveries.clear

      put :submit, params: { id: bgeigie_import.id, api_key: user.authentication_token, file: fixture_file_upload('/bgeigie.log') }

      bgeigie_import.reload
    end

    it { expect(response).to redirect_to(bgeigie_import) }
    it { expect(ActionMailer::Base.deliveries).to be_present }
    it { expect(bgeigie_import.status).to eq('submitted') }
    it { expect(bgeigie_import.rejected).to be_falsey }
    it { expect(bgeigie_import.rejected_by).to be_nil }
  end

  describe 'PATCH #reject' do
    context 'sign in as administrator' do
      context 'processed import without metadata' do
        let(:bgeigie_import) { Fabricate(:bgeigie_import, status: :processed) }

        before do
          sign_in administrator

          # just make sure import has no required metadata
          expect(bgeigie_import).not_to be_metadata_added

          patch :reject, params: { id: bgeigie_import.id }

          bgeigie_import.reload
        end

        it 'should reject import' do
          expect(response).to redirect_to(assigns(:bgeigie_import))
          expect(bgeigie_import).to be_rejected
          expect(bgeigie_import.rejected_by).to eq(administrator.email)
        end
      end
    end
  end

  describe 'PATCH #send_email' do
    let(:bgeigie_import) { Fabricate(:bgeigie_import, status: :unprocessed) }

    before do
      notification = double('notification')
      expect(notification).to receive(:deliver)
      expect(Notifications).to receive(:send_email).and_return(notification)

      sign_in administrator

      patch :send_email, params: { id: bgeigie_import.id, email_body: 'Hello' }

      bgeigie_import.reload
    end

    it 'should create contact history', :aggregate_failures do
      # should redirect to bgeigie_imports#show
      expect(response).to redirect_to(assigns(:bgeigie_import))
      # should change import's status to "waiting for"
      expect(bgeigie_import).to have_attributes(status: 'awaiting_response')
      # should create contact history with administrator and previous status
      expect(bgeigie_import.uploader_contact_histories).to be_exists
      history = bgeigie_import.uploader_contact_histories.first
      expect(history).to have_attributes(administrator: administrator, previous_status: 'unprocessed')
    end
  end

  describe 'PATCH #resolve' do
    let(:bgeigie_import) { Fabricate(:bgeigie_import, status: :awaiting_response) }

    before do
      sign_in administrator
      bgeigie_import.uploader_contact_histories.create(administrator: administrator, previous_status: 'processed')

      patch :resolve, params: { id: bgeigie_import.id }

      bgeigie_import.reload
    end

    it 'should resolve import that has been waited for clarification', :aggregate_failures do
      # should redirect to bgeigie_imports#show
      expect(response).to redirect_to(assigns(:bgeigie_import))
      # should put import's status to previous status
      expect(bgeigie_import).to have_attributes(status: 'processed')
    end
  end
end
