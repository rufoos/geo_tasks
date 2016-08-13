require 'rubygems'
require 'bundler'
require 'sinatra/base'
require 'bson'
require 'mongoid'
require 'pry'

Bundler.require

Dir.glob('./{helpers}/*.rb').sort.each{ |file| require file }
Dir.glob('./{models,lib}/*.rb').sort.each{ |file| require file }

class ApplicationGeoTasks < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :show_exceptions, false

  # Application config in application.yml
  register Sinatra::AppConfig

  # Warden Authentication
  register Sinatra::Auth

  helpers ApplicationHelper
  helpers Sinatra::Parameters

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
    view '/shared/error', {}, { msg: 'not found' }
  end

  error 403 do
    status 403
    view '/shared/error', {}, { msg: 'forbidden' }
  end

  error Mongoid::Errors::DocumentNotFound do
    halt 404
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
    content_type :json
  end

  ## Params
  
  def task_params
    parameters.required(:task).permit(:pickup_coord, :delivery_coord, :title)
  end

  def delete_task_params
    parameters.required(:task).permit(:id)
  end

  def pickup_task_params
    parameters.required(:task).permit(:id)
  end

  def delivered_task_params
    parameters.required(:task).permit(:id)
  end

  def nearby_tasks_params
    parameters.required(:coord).permit(:lat, :lng)
  end

  get '/', auth: 'manager' do
    view '/home/index'
  end

  post '/unauth' do
    403
  end

  ## Tasks
  
  get '/nearby', auth: 'driver' do
    begin
      @tasks = Task.nearby(nearby_tasks_params[:lat], nearby_tasks_params[:lng])
      view '/tasks/nearby'
    rescue ParameterMissing => e
      status 400
      view '/shared/error', {}, { msg: 'missing some parameter' }
    end
  end

  get '/pickup', auth: 'driver' do
    begin
      @task = Task.find(pickup_task_params[:id])
      if @task.pickup!(current_user)
        view '/shared/success', {}, { success: true }
      else
        view '/shared/error', {}, { msg: @task.errors.full_messages }
      end
    rescue ParameterMissing => e
      status 400
      view '/shared/error', {}, { msg: 'missing some parameter' }
    end
  end

  put '/delivered', auth: 'driver' do
    begin
      @task = Task.find(pickup_task_params[:id])
      if @task.delivered!
        view '/shared/success', {}, { success: true }
      else
        view '/shared/error', {}, { msg: @task.errors.full_messages }
      end
    rescue ParameterMissing => e
      status 400
      view '/shared/error', {}, { msg: 'missing some parameter' }
    end
  end
  
  post '/task', auth: 'manager' do
    @task = Task.new(task_params.merge(status: 'new'))
    if @task.save
      view '/tasks/show'
    else
      status 400
      view '/shared/error', {}, { msg: @task.errors.full_messages }
    end
  end

  delete '/task', auth: 'manager' do
    begin
      if delete_task_params
        @task = Task.find(delete_task_params[:id])
        view '/shared/success', {}, { success: @task.destroy }
      end
    rescue ParameterMissing => e
      status 400
      view '/shared/error', {}, { msg: 'missing some parameter' }
    end
  end

end