# ValiMail_DNS-Record-Manager-API

I implemented this as a RESTful API with DNS Zones as a parent object to Record. This API responds to the following routes:
```
GET /api/v1/zone
GET /api/v1/zone/:zid
GET /api/v1/zone/:zid/record
GET /api/v1/zone/:zid/record/:rid
POST /api/v1/zone
POST /api/v1/zone/:zid/record
PUT /api/v1/zone/:zid/record/:rid
DELETE /api/v1/zone/:zid
DELETE /api/v1/zone/:zid/record/:rid
```

## Ruby version

Uses latest stable 2.x Ruby, at the time of this writing is 2.7.2 using asdf (version v0.8.0) with the ruby plugin to install and manage my Rubies.

## System dependencies

I did this work on a MacBook Pro running MacOS 10.15.7

Project uses:
* SQLite3 version 3.34.0
* Rails version 5.2.4.5
* Ruby-Grape version (1.5.2)
* grape-api-generator version (0.1.0)

## Setup
```
gem install bundler
bundle install
```

## Database setup
```
rake db:migrate
```

## Run tests:
```
rake db:test:prepare
bundle exec rspec spec
```

## Run API on localhost
```
RAILS_ENV=development rackup
```

I tested the locally running API service using curl and AdvancedRestClient (https://install.advancedrestclient.com/install).

Here are some example URLs:
```
curl -X GET -H "Content-Type: application/json" http://localhost:9292/api/v1/zone
curl -X GET -H "Content-Type: application/json" http://localhost:9292/api/v1/zone/1
curl -X GET -H "Content-Type: application/json" http://localhost:9292/api/v1/zone/1/record
curl -X GET -H "Content-Type: application/json" http://localhost:9292/api/v1/zone/1/record/2
curl -X POST -H "Content-Type: application/json" -d '{"name":"yahoo.com"}' http://localhost:9292/api/v1/zone
curl -X POST -H "Content-Type: application/json" -d '{"name":"@","record_type":"A","record_data":"10.10.1.1","ttl":14400}' http://localhost:9292/api/v1/zone/1/record
curl -X PUT -H "Content-Type: application/json" -d '{"name":"my.hulabaloo.com"}' http://localhost:9292/api/v1/zone/1/record/1
curl -X DELETE -H "Content-Type: application/json" http://localhost:9292/api/v1/zone/2
curl -X DELETE -H "Content-Type: application/json" http://localhost:9292/api/v1/zone/1/record/1
```
