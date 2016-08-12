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
    view '/error/404'
  end

  error 403 do
    status 403
    view '/error/403'
  end

  set :auth do |*roles|
    condition do
      if !sign_in || !roles.include?(current_user.role)
        403
      end
    end
  end

  before do
    content_type :json
  end

  ## Params
  
  def task_params
    parameters.required(:task).permit(:pickup, :delivery, :title)
  end

  get '/', auth: 'manager' do
    view '/home/index'
  end

  post '/unauth' do
    403
  end

  ## Tasks
  
  post '/task', auth: 'manager' do
    @task = Task.new(task_params)
    if @task.save
      view '/tasks/show'
    else
      view '/error/validation_error', {}, { object: @task }
    end
  end

end