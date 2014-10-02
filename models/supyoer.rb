require 'Digest'

class Supyoer
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :email, String
  property :phone_hash, String
  property :password_hash, String
  property :last_location_lat, Float
  property :last_location_long, Float
  property :last_location_time, DateTime

  def self.hash_val(val)
  	return Digest::SHA1.hexdigest(val.to_s+ENV['SALT'])
  end

  def following
    return Friendship.select{|f| f.first_supyoer_id == self.id}
  end

  def followers
    return Friendship.select{|f| f.second_supyoer_id == self.id}
  end

  def conversations
    return Conversation.select{|c| c.first_supyoer_id == self.id || c.second_supyoer_id == self.id}
  end

end
