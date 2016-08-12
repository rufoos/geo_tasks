class Task
  include Mongoid::Document
  include Mongoid::Paranoia

  field :title, type: String, default: ''
  field :pickup_coord, type: Array
  field :delivery_coord, type: Array
  field :status, type: String
  field :created_at, type: Time
  field :updated_at, type: Time, default: Time.now

  # Relations
  belongs_to :driver, class_name: 'User'

  # Validates
  validates :status, inclusion: { in: %w(new assigned done), message: '"%{value}" is not a valid value' }

  before_create :created_timestamp

  private

  def created_timestamp
    self.created_at = Time.now
  end

end