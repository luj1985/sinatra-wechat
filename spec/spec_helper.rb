require 'coveralls'
Coveralls.wear!

require 'rack/test'
require 'rspec'

require 'sinatra'
require 'sinatra/wechat'

set :environment, :test

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end