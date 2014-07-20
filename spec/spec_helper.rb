require 'rack/test'
require 'rspec'

require 'sinatra'
require 'sinatra/wechat'

require 'coveralls'
Coveralls.wear!

set :environment, :test
