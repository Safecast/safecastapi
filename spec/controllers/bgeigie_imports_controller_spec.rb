RSpec.describe BgeigieImportsController, type: :controller do
  let(:user) { Fabricate(:user) }

  describe 'GET #index', format: :json do
    before do
      args = { cities: 'Tokyo', credits: 'John Doe' }
      %w(None Drive Surface Cosmic).each do |type|
        Fabricate(:bgeigie_import, args.merge(subtype: type))
      end
    end

    subject(:bgeigie_imports) { assigns(:bgeigie_imports) }

    context 'no filter' do
      before do
        get :index, format: :json
      end

      it 'should get all imports' do
        expect(bgeigie_imports.size).to eq(4)
      end
    end

    context 'subtype=Cosmic' do
      before do
        get :index, subtype: 'Cosmic', format: :json
      end

      it 'should filter by subtype' do
        expect(bgeigie_imports.size).to eq(1)
      end
    end

    context 'subtype=Drive,None' do
      before do
        get :index, subtype: 'Drive,None', format: :json
      end

      it 'should filter by subtype' do
        expect(bgeigie_imports.size).to eq(2)
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

      post :create, { format: :json }.merge(post_params)
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
    let(:bgeigie_import) { Fabricate(:bgeigie_import, user: user, cities: 'Tokyo', credits: 'John Doe') }

    before do
      sign_in login_user if login_user

      delete :destroy, id: bgeigie_import.id
    end

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

      it { expect(response) .to redirect_to(new_user_session_path(locale: request.params[:locale])) }
      it 'should not delete bgeigie import' do
        expect { BgeigieImport.find(bgeigie_import.id) }.to_not raise_error
      end
    end
  end
end
