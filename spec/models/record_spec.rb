require 'rails_helper'

RSpec.describe Record do

  subject { record }
  let(:record) do
    Record.new(name: name, record_type: record_type, record_data: record_data, ttl: ttl)
  end

  let(:name) { 'foo.dummy.com' }
  let(:record_type) { 'A' }
  let(:record_data) { '10.10.5.3' }
  let(:ttl) { 3600 }
  let(:zone_name) { 'dummy.com' }

  before(:each) do
    zone = Zone.new(name: zone_name)
    zone.save!
    record.zone = zone
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:record_type) }
    it { is_expected.to validate_presence_of(:record_data) }
    it { is_expected.to validate_presence_of(:ttl) }
    it { is_expected.to validate_presence_of(:zone) }
    it { is_expected.to be_valid }
  end

  context 'name @' do
    let(:name) { '@' }
    it { is_expected.to be_valid }
  end

  context 'name not matching Zone name' do
    let(:zone_name) { 'foo.com' }
    let(:name) { 'bar.com' }
    it { is_expected.not_to be_valid }
  end

  context 'random Zone domain name' do
    let(:zone_name) { Faker::Internet.domain_name }
    let(:name) { Faker::Lorem.word + '.' + zone_name }
    it { is_expected.to be_valid }
  end

  context 'record_type not A or CNAME' do
    let(:record_type) { 'FOO' }
    it { is_expected.not_to be_valid }
  end

  context 'record_type A record_data IP address' do
    let(:record_type) { 'A' }
    let(:record_data) { '22.110.200.123' }
    it { is_expected.to be_valid }
  end

  %w(22.110.200 blech).each do |test|
    context 'record_type A bad record_data' do
      let(:record_type) { 'A' }
      let(:record_data) { test }
      it { is_expected.not_to be_valid }
    end
  end

  context 'record_type CNAME' do
    let(:record_type) { 'CNAME' }
    let(:record_data) { 'bar.com' }
    it { is_expected.to be_valid }
  end

  context 'record_type CNAME random record_data' do
    let(:record_type) { 'CNAME' }
    let(:record_data) { Faker::Internet.domain_name }
    it { is_expected.to be_valid }
  end

  %w(22.110.200.123 blech).each do |test|
    context "record_type CNAME bad record_data #{test}" do
      let(:record_type) { 'CNAME' }
      let(:record_data) { test }
      it { is_expected.not_to be_valid }
    end
  end

  context 'negative ttl' do
    let(:ttl) { -100 }
    it { is_expected.not_to be_valid }
  end

  context 'random ttl' do
    let(:ttl) { rand(100...100000) }
    it { is_expected.to be_valid }
  end

  context 'no Zone' do
    before(:each) do
      record.zone = nil
    end
    it { is_expected.not_to be_valid }
  end

end
