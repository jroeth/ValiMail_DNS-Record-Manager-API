require 'rails_helper'

RSpec.describe DnsManager::V1 do

  let(:v1_url) { '/api/v1' }

  it 'v1 request' do
    get v1_url
    expect(response.status).to eq 200
    expect(response.body).to eq({ 'version': 'v1' }.to_json)
  end

  [ '/',
    '/foo',
    '/api',
    '/api/foo'].each do |bad_url|
    it 'bad url path' do
      get bad_url
      expect(response.status).to eq 404
      expect(response.body).to eq '404 Not Found'
    end
  end

  it 'bad v1 path' do
    get v1_url + '/foo'
    expect(response.status).to eq 404
    expect(response.body).to eq '404 Not Found'
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

  it 'fails to create a new Zone because bad domain name' do
    post '/api/v1/zone', params: { 'name': 'jon.bad' }.to_json, headers: { 'Content-Type': 'application/json' }
    expect(response.status).to eq 400

    body = JSON.parse(response.body)
    expect(body['message']).to eq 'Validation failed: Name is not a fully qualified domain name'
  end

end
