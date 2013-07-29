require 'sinatra'
require_relative './lib/tweet_vault'
require 'rack/cors'

configure :production do
  require 'newrelic_rpm'
end

use Rack::Cors do |config|
  config.allow do |allow|
    allow.origins '*'
    allow.resource '/api/*', :headers => :any, :methods => :get
  end
end

before do
  @vault = TweetVault.new(500) 
end

get '/' do
  "Nothing to see here"
end

get '/api/concepts' do
  content_type :json
  @vault.concepts.to_json
end

get '/api/past_concepts' do
  content_type :json
  @vault.past_concepts.to_json
end

get '/api/future_concepts' do
  content_type :json
  @vault.future_concepts.to_json
end

get '/api/tweeters' do
  content_type :json
  @vault.tweeters.to_json
end
