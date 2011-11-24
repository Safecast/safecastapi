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
    {
      :id => id,
      :name => name,
      :email => email,
      :first_name => first_name,
      :last_name => last_name
    }
  end
  
end