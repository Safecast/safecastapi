module UsersHelper
  def registering?
    params[:user] && params[:user][:name].present?
  end
end
