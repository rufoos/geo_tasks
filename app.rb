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

  # Application config in application.yml
  register Sinatra::AppConfig

  # Warden Authentication
  set :session_secret, settings.app_config['warden']['session_key']
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
    view '/error/404'
  end

  set :auth do |*roles|
    condition do
      sign_in
    end
  end

  get '/', auth: :driver do
    view '/home/index'
  end

  post '/unauth' do
    status 403
    view '/error/403'
  end

end