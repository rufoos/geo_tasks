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
    view :'/error/404'
  end

  def view(template, options = {})
    content_type :json
    jbuilder template.to_sym
  end

  get '/' do
    view '/home/index'
  end

end