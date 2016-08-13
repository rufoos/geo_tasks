class Task
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Geospatial

  field :title, type: String, default: ''
  field :pickup_coord, type: Point, sphere: true
  field :delivery_coord, type: Point
  field :status, type: String
  field :created_at, type: Time
  field :updated_at, type: Time, default: Time.now

  # Relations
  belongs_to :driver, class_name: 'User'

  # Validates
  validates :status, inclusion: { in: %w(new assigned done), message: '"%{value}" is not a valid value' }

  before_create :created_timestamp

  scope :newest, ->{ where(status: 'new') }
  scope :assigned_for_driver, ->(driver){ where(status: 'assigned', driver_id: driver.id) }

  def pickup!(driver)
    self.driver = driver
    self.status = 'assigned'
    save
  end

  def delivered!
    self.status = 'done'
    save
  end

  def self.nearby(lat, lng, max_distance = 400)
    Task.collection.aggregate({
      '$geoNear': {
        near: { type: "Point", coordinates: [lng.to_f, lat.to_f] },
        distanceField: "dist.calculated",
        includeLocs: "dist.pickup_coord",
        maxDistance: max_distance.to_f,
        query: { status: 'new' },
        spherical: true
      }
    })
  end

  private

  def created_timestamp
    self.created_at = Time.now
  end

end