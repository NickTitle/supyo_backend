require 'Digest'

class Supyoer
  include DataMapper::Resource

  property :id, Serial
  property :name,                 String, :unique   => true, :required => true
  property :phone_hash,           String, :unique   => true
  property :password_hash,        String
  property :latitude,             Float
  property :longitude,            Float

  def self.hash_val(val)
  	return Digest::SHA2.hexdigest(val.to_s+ENV['SALT'])
  end

  def following
    return Friendship.select{|f| f.first_supyoer_id == self.id}.map{|f| Supyoer.get(f.second_supyoer_id)}
  end

  def followers
    return Friendship.select{|f| f.second_supyoer_id == self.id}.map{|f| Supyoer.get(f.first_supyoer_id)}
  end

  def conversations
    return Conversation.select{|c| c.first_supyoer_id == self.id || c.second_supyoer_id == self.id}
  end

  def generate_contacts_from_phone_hash_array(phone_hash_array)
    found_supyoers = Supyoer.all(:phone_hash => phone_hash_array)
    found_supyoers.each do |supyoer|
      f = Friendship.new
      f.first_supyoer_id  = self.id
      f.second_supyoer_id = supyoer.id
      f.save
    end

    found_supyoers.map {|s| s.returned_supyoer_hash}
  end

  def returned_supyoer_hash(supyoer=nil)
    if supyoer and !SharedLocation.select{|sl| sl.sharing_supyoer_id == id && sl.shared_to_supyoer_id == supyoer.id}.empty?
      return {:id =>self.id, :name =>self.name, :latitude =>self.latitude, :longitude=>self.longitude}
    else
      return {:id =>self.id, :name => self.name}
    end
  end

end
