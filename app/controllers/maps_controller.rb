class MapsController < SiteApplicationController
  
  def show
    @map = Map.find(params[:id])
  end
  
end