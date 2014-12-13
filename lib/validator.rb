require 'digest'

module Supyo
  class Validator

  	def self.validate_request_for_user(request, user_id, hash)
  		return false unless (request && user_id && hash)

  		supyoer 	= Supyoer.get(user_id)
  		user_token 	= Token.first(:phone_hash => supyoer.phone_hash).name
      return false unless (supyoer && user_token)

  		request_body = JSON.parse(request.body.read).to_s.gsub('=>',':').gsub(' ', '')
      string_to_digest = request_body+user_token
      digest = Digest::SHA2.hexdigest(string_to_digest)
      return (digest == hash)
  	end

  	def self.validate_get_request_for_user(user_id, nonce, hash)
  		return false unless (user_id && nonce && hash)

      supyoer   = Supyoer.get(user_id)
      user_token  = Token.first(:phone_hash => supyoer.phone_hash).name
      return false unless (supyoer && user_token)
      
      string_to_digest = nonce+user_token
      digest = Digest::SHA2.hexdigest(string_to_digest)
      return (digest == hash)
  	end

  	def self.nonce
  		return rand(36**length).to_s(36)
  	end

  end
end