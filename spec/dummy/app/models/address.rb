
class Address < ActiveRecord::Base
  has_one :registration, inverse_of: :address,
end

