require 'digest'

module Supyo
  class Validator

  	def self.validate_request(nonce, hash)
  		return false if hash == nil || nonce == nil
  		return (Digest::SHA2.hexdigest(nonce+SALT) == hash)
  	end

  	def self.nonce
  		return rand(36**length).to_s(36)
  	end

  end
end