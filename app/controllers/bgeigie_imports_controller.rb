class BgeigieImportsController < SiteApplicationController
  def index
    @public_bgeigie_imports = BgeigieImport.done.newest
    if user_signed_in?
      @your_bgeigie_imports = current_user.bgeigie_imports.newest
      @unapproved_bgeigie_imports = BgeigieImport.unapproved.newest if current_user.moderator?
    end
  end

  def show
    @bgeigie_import = BgeigieImport.find(params[:id])
  end
end