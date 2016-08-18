require 'rubygems'
require 'bundler'
require 'sinatra/base'
require 'bson'
require 'mongoid'
require 'pry'
require 'json'

Bundler.require

Dir.glob('./{helpers}/*.rb').sort.each{ |file| require file }
Dir.glob('./{models,lib}/*.rb').sort.each{ |file| require file }

class ApplicationGeoTasks < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :show_exceptions, false

  # Warden Authentication
  register Sinatra::Auth

  helpers ApplicationHelper

  enable :sessions, :method_override
  enable :raise_exceptions

  configure do
    enable :logging, :dump_errors, :raise_errors
    file = File.open("#{settings.root}/log/#{settings.environment}.log", 'a+')
    file.sync = true
    use Rack::CommonLogger, file

    # Mongo config
    mongo_config = File.expand_path('config/mongoid.yml', File.dirname(__FILE__))
    Mongoid.load!(mongo_config)
  end

  not_found do
    json error_msg: 'not found'
  end

  error 403 do
    status 403
    json error_msg: 'forbidden'
  end

  error Mongoid::Errors::DocumentNotFound do
    halt 404
  end

  error Mongoid::Errors::InvalidFind do
    status 400
    json error_msg: 'invalid field for find'
  end

  error RuntimeError do
    status 400
    json error_msg: 'runtime error'
  end

  set :auth do |*roles|
    condition do
      sign_in
      if current_user.nil? || !roles.flatten.include?(current_user.role)
        halt 403
      end
    end
  end

  before do
    parse_body_json_params
    content_type :json
  end

  get '/' do
    json content: 'hello geo tasks'
  end

  post '/unauth' do
    403
  end

  ## Tasks
  
  post '/nearby', auth: 'driver' do
    tasks = Task.nearby(params[:lat], params[:lng])
    res =
      tasks.map do |task|
        {
          id: task['_id'],
          title: task['title'],
          pickup_coord: { lat: task['pickup_coord'].last, lng: task['pickup_coord'].first },
          delivery_coord: { lat: task['delivery_coord'].last, lng: task['delivery_coord'].first },
          distance: task['dist']['calculated'],
          status: task['status'],
          created_at: task['created_at'],
          updated_at: task['updated_at']
        }
      end
    json res
  end

  post '/pickup', auth: 'driver' do
    task = Task.find(params[:id])
    if task.pickup!(current_user)
      json success: true
    else
      json error_msg: task.errors.full_messages
    end
  end

  put '/delivered', auth: 'driver' do
    task = Task.find(params[:id])
    if task.delivered!
      json success: true
    else
      json error_msg: task.errors.full_messages
    end
  end
  
  post '/task', auth: 'manager' do
    task = Task.new(params.merge(status: 'new'))
    if task.save
      Task.create_indexes
      res = {
        id: task.id,
        title: task.title,
        pickip_coord: {
          lat: task.pickup_coord.to_hsh(:lat, :lng)[:lat],
          lng: task.pickup_coord.to_hsh(:lat, :lng)[:lng]
        },
        delivery_coord: {
          lat: task.delivery_coord.to_hsh(:lat, :lng)[:lat],
          lng: task.delivery_coord.to_hsh(:lat, :lng)[:lng]
        },
        status: task.status,
        created_at: task.created_at,
        updated_at: task.updated_at
      }
      json res
    else
      status 400
      json error_msg: task.errors.full_messages
    end
  end

  delete '/task', auth: 'manager' do
    task = Task.find(params[:id])
    json success: task.destroy
  end

  ## Statistics
  
  post '/stat', auth: 'manager' do
    drivers = User.where(role: 'driver').to_a
    stats = Task.stat('$driver_id', { status: 'done' })
    total_length = Task.stat.first

    res_stats =
      stats.map do |stat|
        sel_driver = drivers.select{ |d| d.id == stat['_id'] }.first
        {
          driver: { id: sel_driver.id, name: sel_driver.name },
          total_length: stat['totalLength'],
          processed_tasks: stat['count']
        }
      end
    res = { by_drivers: res_stats }
    if total_length
      res.merge!({
        total: { length: total_length['totalLength'], tasks: total_length['count'] }
      })
    end

    json res
  end

end