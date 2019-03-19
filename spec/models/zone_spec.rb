require 'rails_helper'

RSpec.describe Zone do

  subject { zone }
  let(:zone) do
    Zone.new(name: zone_name)
  end

  let(:zone_name) { 'dummy.com' }

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to be_valid }
  end

  context 'is not valid without a name' do
    let(:zone_name) { nil }
    it { is_expected.not_to be_valid }
  end

  context 'is not valid without a proper domain name' do
    let(:zone_name) { 'dummy' }
    it { is_expected.not_to be_valid }
  end

  context 'random domain name' do
    let(:zone_name) { Faker::Internet.domain_name }
    it { is_expected.to be_valid }
  end

end
