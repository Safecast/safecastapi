class BgeigieImportsController < SiteApplicationController
  has_scope :by_status
  has_scope :by_user_id

  def index
    @bgeigie_imports = apply_scopes(BgeigieImport).page(params[:page])
  end

  def show
    @bgeigie_import = BgeigieImport.find(params[:id])
  end
end