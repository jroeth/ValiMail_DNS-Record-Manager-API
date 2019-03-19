class Zone < ApplicationRecord
  validates_presence_of :name
  validates :name, domainname: true

end
