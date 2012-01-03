class Users::SessionsController < Devise::SessionsController
  def create
    
    if params[:user][:name].present?
      build_resource
      if resource.save
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        clean_up_passwords(resource)
        respond_with_navigational(resource) { render_with_scope :new }
      end
    else
      resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
      sign_in(resource_name, resource)
      respond_with resource, :location => after_sign_in_path_for(resource)
    end
  end
  
private
  def build_resource(hash=nil)
    hash ||= params[resource_name] || {}
    self.resource = resource_class.new_with_session(hash, session)
  end

  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end
  
end
