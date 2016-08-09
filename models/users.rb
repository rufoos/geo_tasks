class User
  include Mongoid::Document

  field :auth_token, type: String, default: ''
  field :name, type: String
  field :role, type: String
  field :created_at, type: Time
  field :updated_at, type: Time, default: Time.now
  field :deleted_at, type: Time

  has_many :tasks

end