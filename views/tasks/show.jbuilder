json.id @task.id
json.title @task.title
json.pickip do
  json.lat @task.pickup_coord.first
  json.lng @task.pickup_coord.last
end
json.delivery do
  json.lat @task.delivery_coord.first
  json.lng @task.delivery_coord.last
end
json.status @task.status
json.created_at @task.created_at
json.updated_at @task.updated_at