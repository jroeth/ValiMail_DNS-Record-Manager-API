require 'ipaddress'

class Record < ApplicationRecord
  belongs_to :zone, inverse_of: :records

  validates_presence_of :name, :record_type, :record_data, :ttl, :zone
  validates :record_type, inclusion: { in: %w(A CNAME) }
  validates :ttl, numericality: { only_integer: true, greater_than: 0 }
  validates :record_data, domainname: true, if: :is_cname_record_type?

  validate :name_is_root_domain_or_subdomain, :valid_a_record_data

  def name_is_root_domain_or_subdomain
    if name.present? && zone.present?
      if !name.eql?('@') && !name.end_with?(zone.name)
        errors.add(:name, "#{name} is not root domain or not subdomain of #{zone.name}")
      end
    end
  end

  def is_cname_record_type?
    record_type.eql?('CNAME')
  end

  def valid_a_record_data
    if record_type.present? && record_type.eql?('A')
      if !IPAddress.valid?(record_data)
        errors.add(:record_data, "#{record_data} not valid A record")
      end
    end
  end

end
