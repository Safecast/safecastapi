class User < ActiveRecord::Base
  
  include UserConcerns
  
  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  
  def serializable_hash(options = {})
    options ||= {}
    options[:only] = [:id, :name, :email]
    options[:methods] = [:first_name, :last_name]
    super(options)
  end
  
end