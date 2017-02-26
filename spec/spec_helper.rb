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

  c.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  c.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end
end