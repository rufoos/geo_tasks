json.by_drivers do
  json.array! @stats do |stat|
    sel_driver = @drivers.select{ |d| d.id == stat['_id'] }.first
    json.driver do
      json.id sel_driver.id
      json.name sel_driver.name
    end
    json.total_length stat['totalLength']
    json.processed_tasks stat['count']
  end
end

if @total_length
  json.total do
    json.length @total_length['totalLength']
    json.tasks @total_length['count']
  end
end