require 'sinatra'

before do
  request.body.rewind
  @request_payload = JSON.parse request.body.read
end

post '/card_moved' do
  puts @request_payload
  "Hello, world"
end
