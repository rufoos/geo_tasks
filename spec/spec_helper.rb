require 'rack/test'
require 'rspec'
require 'factory_girl'

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../app.rb', __FILE__
Dir.glob('./spec/support/**/*.rb').each { |f| require f }

module RSpecMixin
  include Rack::Test::Methods

  def app() ApplicationGeoTasks end
end

RSpec.configure do |c|
  c.include RSpecMixin
  c.include AuthHelper
  c.include FactoryGirl::Syntax::Methods

  c.after do
    FactoryGirl.reload
  end

  c.before(:suite) do
    FactoryGirl.find_definitions
  end
end