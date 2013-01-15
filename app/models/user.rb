class User < ActiveRecord::Base
  
  include UserConcerns

  has_many :bgeigie_imports
  has_many :measurements
  has_many :maps

  scope :moderator, where(:moderator => true)
  
  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me,
                  :time_zone

  validates :name, :presence => true
  
  before_save :ensure_authentication_token

  def serializable_hash(options = {})
    super options.merge(
      :only => [:id, :name, :email, :authentication_token],
      :methods => [:first_name, :last_name]
    )
  end

  def name_or_email
    name.presence || email
  end
  
end