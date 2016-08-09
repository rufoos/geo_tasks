class Task
  include Mongoid::Document
  include Mongoid::Paranoia

  field :title, type: String, default: ''
  field :lat, type: Float
  field :lng, type: Float
  field :status, type: String
  field :created_at, type: Time
  field :updated_at, type: Time, default: Time.now

  # Relations
  belongs_to :user

  # Validates
  validates :lat, :lng, presence: true
  validates :status, inclusion: { in: %w(new assigned done), message: '%{value} is not a valid value' }

end