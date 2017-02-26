source "https://rubygems.org"

gem 'sinatra'
gem 'rake'

# server, to run: bundle exec thin -p 4567 start
gem "thin"

# DataBase
gem 'mongoid'
gem 'bson_ext'
gem 'mongoid-geospatial'

gem 'rgeo'

# auth
gem 'warden'

group :development do
  gem 'pry'

  # auto-reload then changes app https://github.com/alexch/rerun
  # then server must run this command:
  # bundle exec rerun -- thin start --port=4567 -R config.ru
  gem 'rerun'
end

group :test do
  gem 'rack-test', require: 'rack/test'
  gem 'rspec'
  gem "factory_girl", "~> 4.0"
  gem 'database_cleaner'

  gem 'mutant', :git => 'https://github.com/mbj/mutant.git'
  gem 'mutant-rspec'
  gem 'rspec-expectations'
  gem 'rspec-mocks'
  gem 'pry-byebug'
end