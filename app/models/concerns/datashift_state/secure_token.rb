# This file lifted from https://github.com/robertomiranda/has_secure_token
# which is part of a back-port of has_secure_token from Rails 5 to Rails 4.
# Because has_secure_token in Rails 5 is still under review (Base58 has
# MySQL compatability issues when in case insenstive mode, as it generates upper
# and lower case letters) there is a chance that the implementation of the has_secure_token
# gem will change.
#
module DatashiftState
  module SecureToken
    extend ActiveSupport::Concern

    TOKEN_LENGTH = 34

    # Example using has_secure_token
    #
    #   # Schema: User(token:string, auth_token:string)
    #   class User < ActiveRecord::Base
    #     include SecureToken
    #     has_secure_token
    #     has_secure_token :auth_token
    #   end
    #
    #   user = User.new
    #   user.save
    #   user.token # => "pX27zsMN2ViQKta1bGfLmVJE"
    #   user.auth_token # => "77TMHrHJFvFDwodq8w7Ev2m7"
    #   user.regenerate_token # => true
    #   user.regenerate_auth_token # => true
    #
    # SecureRandom::base58 is used to generate the 24-character unique token, so collisions are highly unlikely.
    #
    # Note that it's still possible to generate a race condition in the database in the same way that
    # <tt>validates_uniqueness_of</tt> can. You're encouraged to add a unique index in the database to deal
    # with this even more unlikely scenario.

    included do
      def has_secure_token(attribute = :token)
        # Load securerandom only when has_secure_token is used.
        require 'active_support/core_ext/securerandom'
        define_method("regenerate_#{attribute}") do
          update_attributes attribute => self.class.generate_unique_secure_token
        end
        before_create do
          send("#{attribute}=", self.class.generate_unique_secure_token) unless send("#{attribute}?")
        end
      end

      def generate_unique_secure_token(length = TOKEN_LENGTH)
        SecureRandom.base58(length)
      end
    end

  end
end
