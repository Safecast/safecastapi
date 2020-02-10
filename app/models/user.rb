# frozen_string_literal: true

class User < ActiveRecord::Base
  include UserConcerns
  include Swagger::Blocks

  swagger_schema :User do
    key :required, %i(id email name)
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :name do
      key :type, :string
    end
    property :measurements_count do
      key :type, :integer
      key :format, :int64
    end
  end

  has_many :bgeigie_imports
  has_many :measurements
  has_many :maps

  scope :moderator, -> { where(moderator: true) }

  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  # TODO: remove later
  # Setup accessible (or protected) attributes for your model
  # attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :time_zone, :default_locale

  validates :email, presence: true
  validates :name, presence: true

  before_save :ensure_authentication_token

  def self.by_name(q)
    where('lower(name) LIKE ?', "%#{q.downcase}%")
  end

  def serializable_hash(options = {})
    super options.merge(
      only: %i(id name email authentication_token),
      methods: %i(first_name last_name)
    )
  end

  def to_builder
    Jbuilder.new do |user|
      user.call(self, :id, :name, :number_of_measurements)
    end
  end

  def name_or_email
    name.presence || email
  end
end
