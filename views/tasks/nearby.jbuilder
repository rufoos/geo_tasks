json.array! @tasks do |task|
  json.id task['_id']
  json.extract! task, 'title', 'status', 'created_at', 'updated_at'
  json.pickip_coord do
    json.lat task['pickup_coord'].last
    json.lng task['pickup_coord'].first
  end
  json.delivery_coord do
    json.lat task['delivery_coord'].last
    json.lng task['delivery_coord'].first
  end
  json.distance task['dist']['calculated']
end