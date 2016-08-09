require 'sinatra/asset_pipeline/task'
require './app'
require 'rake'

Dir.glob('./{tasks}/*.rake').sort.each{ |file| load file }
Sinatra::AssetPipeline::Task.define! ApplicationGeoTasks