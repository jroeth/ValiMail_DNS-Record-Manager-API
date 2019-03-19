require 'rails_helper'

RSpec.describe DnsManager::V1 do

  it 'v1 request' do
    get '/api/v1'
    expect(response.status).to eq 200
    expect(response.body).to eq({ 'version': 'v1' }.to_json)
  end

  it 'bad path' do
    expect { get '/api/foo' }.to raise_error(ActionController::RoutingError)
  end

  it 'create a new Zone' do
    post '/api/v1/zone', params: { 'name': 'jon.com' }.to_json, headers: { 'Content-Type': 'application/json' }
    expect(response.status).to eq 201

    body = JSON.parse(response.body)
    expect(body['id']).to eq 1
    expect(body['name']).to eq 'jon.com'
    expect(Time.parse(body['created_at'])).to be_within(1.second).of Time.now.utc
    expect(Time.parse(body['updated_at'])).to be_within(1.second).of Time.now.utc
  end


end
