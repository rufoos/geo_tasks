require 'digest'

namespace :db do
  task :seed do
    User.delete_all
    Task.collection.drop

    5.times do |i|
      User.create(
        name: "Manager ##{i + 1}",
        auth_token: Digest::MD5.hexdigest("--manager-#{i}-token--#{Time.now.to_i}"),
        role: 'manager'
      )
    end

    10.times do |i|
      User.create(
        name: "Driver ##{i + 1}",
        auth_token: Digest::MD5.hexdigest("--driver-#{i}-token--#{Time.now.to_i}"),
        role: 'driver'
      )
    end

    drivers = User.where(role: 'driver').to_a
    drivers << nil
    100000.times do |i|
      pickup_lat = 59.0 + rand(0..2.0).round(6)
      pickup_lng = 30.0 + rand(0..2.0).round(6)
      delivery_lat = 59.0 + rand(0..2.0).round(6)
      delivery_lng = 30.0 + rand(0..2.0).round(6)

      driver = drivers.sample

      data = {
        title: "Cargo ##{i + 1}",
        pickup_coord: { lat: pickup_lat, lng: pickup_lng },
        delivery_coord: { lat: delivery_lat, lng: delivery_lng },
        status: 'new'
      }

      if driver
        data[:status] = %w(assigned done).sample
        data[:driver] = driver
      end

      Task.create(data)
    end

    Task.create_indexes
  end
end