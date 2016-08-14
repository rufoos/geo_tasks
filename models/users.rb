class User
  include Mongoid::Document

  field :auth_token, type: String, default: ''
  field :name, type: String
  field :role, type: String
  field :created_at, type: Time
  field :updated_at, type: Time, default: Time.now

  has_many :tasks

  before_create :created_timestamp

  def self.authenticate_by_token(token)
    User.where(auth_token: token).first
  end

  private

  def created_timestamp
    self.created_at = Time.now
  end

end