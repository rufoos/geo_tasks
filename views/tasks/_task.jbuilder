json.extract! task, :id, :title, :status, :created_at, :updated_at
json.pickip_coord do
  json.lat task.pickup_coord.to_hsh(:lat, :lng)[:lat]
  json.lng task.pickup_coord.to_hsh(:lat, :lng)[:lng]
end
json.delivery_coord do
  json.lat task.delivery_coord.to_hsh(:lat, :lng)[:lat]
  json.lng task.delivery_coord.to_hsh(:lat, :lng)[:lng]
end