require 'json'
require 'sinatra'

set :bind, '0.0.0.0'

def data
  JSON.parse(File.read('data.json'))
end

before do
  content_type :json
end

get '/' do
  data.to_json
end

get '/number' do
  { number: data['number'] }.to_json
end
