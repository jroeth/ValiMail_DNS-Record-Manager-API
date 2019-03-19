require 'rails_helper'

RSpec.describe DnsManager::V1 do

  let(:v1_url) { '/api/v1' }
  let (:json_headers) { { 'Content-Type': 'application/json' } }

  it 'v1 request' do
    get v1_url, headers: json_headers
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
    get v1_url + '/foo', headers: json_headers
    expect(response.status).to eq 404
    expect(response.body).to eq '404 Not Found'
  end

  let (:zone_url) { v1_url + '/zone'}

  it 'create a new Zone' do
    post zone_url, params: { 'name': 'jon.com' }.to_json, headers: json_headers
    expect(response.status).to eq 201
    verify_zone_json(JSON.parse(response.body), 1, 'jon.com')
  end

  it 'fails to create a new Zone because bad domain name' do
    post zone_url, params: { 'name': 'jon.bad' }.to_json, headers: json_headers
    expect(response.status).to eq 400
    json = JSON.parse(response.body)
    expect(json['error']).to eq 'Validation failed: Name is not a fully qualified domain name'
  end

  it 'fails to retrieve a Zone that does not exist' do
    get zone_url + '/1', headers: json_headers
    expect(response.status).to eq 404
    json = JSON.parse(response.body)
    expect(json['error']).to eq '404 Record not found.'
  end

  it 'create new Zones, retrieve, delete' do
    post zone_url, params: { 'name': 'jon.com' }.to_json, headers: json_headers
    expect(response.status).to eq 201
    verify_zone_json(JSON.parse(response.body), 1, 'jon.com')

    post zone_url, params: { 'name': 'jon.us' }.to_json, headers: json_headers
    expect(response.status).to eq 201
    verify_zone_json(JSON.parse(response.body), 2, 'jon.us')

    get zone_url, headers: json_headers
    expect(response.status).to eq 200
    json = JSON.parse(response.body)
    expect(json.size).to eq 2
    verify_zone_json(json[0], 1, 'jon.com')
    verify_zone_json(json[1], 2, 'jon.us')

    get zone_url + '/2', headers: json_headers
    expect(response.status).to eq 200
    verify_zone_json(JSON.parse(response.body), 2, 'jon.us')

    delete zone_url + '/2', headers: json_headers
    expect(response.status).to eq 200
    verify_zone_json(JSON.parse(response.body), 2, 'jon.us')

    get zone_url + '/2', headers: json_headers
    expect(response.status).to eq 404
    json = JSON.parse(response.body)
    expect(json['error']).to eq '404 Record not found.'

    get zone_url, headers: json_headers
    expect(response.status).to eq 200
    json = JSON.parse(response.body)
    expect(json.size).to eq 1
    verify_zone_json(json[0], 1, 'jon.com')
  end

  context 'valid Zone for Record operations' do
    let(:zone_id) { 1 }
    let(:zone_name) { 'dum.com' }
    let(:record_url) { zone_url + '/' + zone_id.to_s + '/record' }

    before(:each) do
      post zone_url, params: { 'name': zone_name }.to_json, headers: json_headers
      expect(response.status).to eq 201
      verify_zone_json(JSON.parse(response.body), zone_id, zone_name)
    end

    it 'has no Records' do
      get record_url, headers: json_headers
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json.size).to eq 0
    end

    it 'create a new Record' do
      post record_url,
        params: { 'name': '@', 'record_type': 'A', 'record_data': '10.10.1.1' }.to_json,
        headers: json_headers
      expect(response.status).to eq 201
      verify_record_json(JSON.parse(response.body), 1, '@', 'A', '10.10.1.1', 3600, zone_id)

      get record_url + '/1', headers: json_headers
      expect(response.status).to eq 200
      verify_record_json(JSON.parse(response.body), 1, '@', 'A', '10.10.1.1', 3600, zone_id)

      get record_url, headers: json_headers
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json.size).to eq 1
      verify_record_json(json[0], 1, '@', 'A', '10.10.1.1', 3600, zone_id)
    end

    it 'fails to create a BAD Record' do
      post record_url,
        params: { 'name': '@', 'record_type': 'A', 'record_data': 'foo.bar' }.to_json,
        headers: json_headers
      expect(response.status).to eq 400
      json = JSON.parse(response.body)
      expect(json['error']).to eq 'Validation failed: Record data foo.bar not valid A record'
    end

    it 'updates a Record' do
      post record_url,
        params: { 'name': '@', 'record_type': 'A', 'record_data': '10.10.1.1' }.to_json,
        headers: json_headers
      expect(response.status).to eq 201
      verify_record_json(JSON.parse(response.body), 1, '@', 'A', '10.10.1.1', 3600, zone_id)

      new_name = 'ran.' + zone_name
      put record_url + '/1', params: { 'name': new_name }
      expect(response.status).to eq 200
      verify_record_json(JSON.parse(response.body), 1, new_name, 'A', '10.10.1.1', 3600, zone_id)

      get record_url + '/1', headers: json_headers
      expect(response.status).to eq 200
      verify_record_json(JSON.parse(response.body), 1, new_name, 'A', '10.10.1.1', 3600, zone_id)

      get record_url, headers: json_headers
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json.size).to eq 1
      verify_record_json(json[0], 1, new_name, 'A', '10.10.1.1', 3600, zone_id)
    end

    it 'fails to update a Record with BAD data' do
      orig_name = '@'
      post record_url,
        params: { 'name': orig_name, 'record_type': 'A', 'record_data': '10.10.1.1' }.to_json,
        headers: json_headers
      expect(response.status).to eq 201
      verify_record_json(JSON.parse(response.body), 1, '@', 'A', '10.10.1.1', 3600, zone_id)

      get record_url + '/1', headers: json_headers
      expect(response.status).to eq 200
      verify_record_json(JSON.parse(response.body), 1, orig_name, 'A', '10.10.1.1', 3600, zone_id)

      new_name = 'hoser'
      put record_url + '/1', params: { 'name': new_name }
      expect(response.status).to eq 400
      json = JSON.parse(response.body)
      expect(json['error']).to eq "Validation failed: Name #{new_name} is not root domain or not subdomain of #{zone_name}"

      get record_url + '/1', headers: json_headers
      expect(response.status).to eq 200
      verify_record_json(JSON.parse(response.body), 1, orig_name, 'A', '10.10.1.1', 3600, zone_id)

      get record_url, headers: json_headers
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json.size).to eq 1
      verify_record_json(json[0], 1, orig_name, 'A', '10.10.1.1', 3600, zone_id)
    end

    it 'deletes a Record' do
      post record_url,
        params: { 'name': '@', 'record_type': 'A', 'record_data': '10.10.1.1' }.to_json,
        headers: json_headers
      expect(response.status).to eq 201
      verify_record_json(JSON.parse(response.body), 1, '@', 'A', '10.10.1.1', 3600, zone_id)

      get record_url + '/1', headers: json_headers
      expect(response.status).to eq 200
      verify_record_json(JSON.parse(response.body), 1, '@', 'A', '10.10.1.1', 3600, zone_id)

      delete record_url + '/1', headers: json_headers
      expect(response.status).to eq 200
      verify_record_json(JSON.parse(response.body), 1, '@', 'A', '10.10.1.1', 3600, zone_id)

      get record_url + '/1', headers: json_headers
      expect(response.status).to eq 404
      json = JSON.parse(response.body)
      expect(json['error']).to eq '404 Record not found.'

      get record_url, headers: json_headers
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json.size).to eq 0
    end

    it 'fails to delete a Record' do
      post record_url,
        params: { 'name': '@', 'record_type': 'A', 'record_data': '10.10.1.1' }.to_json,
        headers: json_headers
      expect(response.status).to eq 201
      verify_record_json(JSON.parse(response.body), 1, '@', 'A', '10.10.1.1', 3600, zone_id)

      get record_url + '/1', headers: json_headers
      expect(response.status).to eq 200
      verify_record_json(JSON.parse(response.body), 1, '@', 'A', '10.10.1.1', 3600, zone_id)

      delete record_url + '/2', headers: json_headers
      expect(response.status).to eq 404
      json = JSON.parse(response.body)
      expect(json['error']).to eq '404 Record not found.'

      get record_url, headers: json_headers
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json.size).to eq 1
      verify_record_json(json[0], 1, '@', 'A', '10.10.1.1', 3600, zone_id)
    end
  end

  def verify_zone_json(json, id, name)
    expect(json['id']).to eq id
    expect(json['name']).to eq name
    expect(Time.parse(json['created_at'])).to be_within(1.second).of Time.now.utc
    expect(Time.parse(json['updated_at'])).to be_within(1.second).of Time.now.utc
  end

  def verify_record_json(json, id, name, record_type, record_data, ttl, zone_id)
    expect(json['id']).to eq id
    expect(json['name']).to eq name
    expect(json['record_type']).to eq record_type
    expect(json['record_data']).to eq record_data
    expect(json['ttl']).to eq ttl
    expect(json['zone_id']).to eq zone_id
    expect(Time.parse(json['created_at'])).to be_within(1.second).of Time.now.utc
    expect(Time.parse(json['updated_at'])).to be_within(1.second).of Time.now.utc
  end

end
