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
end
