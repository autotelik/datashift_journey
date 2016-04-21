# This file lifted from https://github.com/robertomiranda/has_secure_token
# which is part of a back-port of has_secure_token from Rails 5 to Rails 4.
# Because has_secure_token in Rails 5 is still under review (Base58 has
# MySQL compatability issues when in case insenstive mode, as it generates upper
# and lower case letters) there is a chance that the implementation of the has_secure_token
# gem will change.
#
require 'securerandom'

module SecureRandom
  BASE58_ALPHABET = ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a - %w(0 O I l)
  # SecureRandom.base58 generates a random base58 string.
  #
  # The argument _n_ specifies the length, of the random string to be generated.
  #
  # If _n_ is not specified or is nil, 16 is assumed. It may be larger in the future.
  #
  # The result may contain alphanumeric characters except 0, O, I and l
  #
  #   p SecureRandom.base58 #=> "4kUgL2pdQMSCQtjE"
  #   p SecureRandom.base58(24) #=> "77TMHrHJFvFDwodq8w7Ev2m7"
  #
  def self.base58(n = 16)
    SecureRandom.random_bytes(n).unpack('C*').map do |byte|
      idx = byte % 64
      idx = SecureRandom.random_number(58) if idx >= 58
      BASE58_ALPHABET[idx]
    end.join
  end
end
