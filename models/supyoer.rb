require 'Digest'

class Supyoer
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :unique => true, :required => true
  property :email, String, :unique => true
  property :phone_hash, String, :unique => true
  property :password_hash, String
  property :last_location_lat, Float
  property :last_location_long, Float
  property :last_location_time, DateTime

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

      if f.save
        puts "Friendship saved"
      else
        puts "Friendship not saved"
      end
    end

    found_supyoers.map {|s| s.returned_supyoer_hash}
  end

  def returned_supyoer_hash
    return {:id =>self.id, :name => self.name}
  end

end
