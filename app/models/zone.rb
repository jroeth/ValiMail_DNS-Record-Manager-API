class Zone < ApplicationRecord

  has_many :records, :dependent => :destroy, :inverse_of => :zone

  validates_presence_of :name
  validates :name, domainname: true

end
