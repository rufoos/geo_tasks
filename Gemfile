source "https://rubygems.org"

gem 'sinatra'
gem 'rake'

# server, to run: bundle exec thin -p 4567 start
gem "thin"

# templater
gem "tilt-jbuilder", ">= 0.4.0", :require => "sinatra/jbuilder"

# Routing
gem 'rack-mount'

# DataBase
gem 'mongoid'
gem 'bson_ext'
gem 'mongoid-paranoia'

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
  gem "rack-test", require: "rack/test"
  gem 'rspec'
end