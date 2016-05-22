require_dependency "has_secure_token"

class Checkout < ActiveRecord::Base

  has_secure_token

  def to_param
    token
  end

  belongs_to :bill_address, class_name: "Address"
  belongs_to :ship_address, class_name: "Address"
  belongs_to :payment

  def payment_card
   (payment.present?) ? payment.card : ""
  end

end
