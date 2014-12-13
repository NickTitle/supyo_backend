class Supyoer
  include DataMapper::Resource

  property :id, Serial
  property :name,                 String, :unique   => true, :required => true
  property :phone_hash,           String, :unique   => true
  property :password_hash,        String
  property :latitude,             Float
  property :longitude,            Float
  property :created_at,           DateTime

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
    now = DateTime.now.to_time.to_f
    found_supyoers = Supyoer.all(:phone_hash => phone_hash_array)
    new_friendships = []
    found_supyoers.each do |supyoer|
      f = Friendship.new
      f.first_supyoer_id  = self.id
      f.second_supyoer_id = supyoer.id
      if f.save
        new_friendships << supyoer.name
      end
    end
    if new_friendships.count > 0
      new_friendships
    else
      []
    end
  end

  def returned_supyoer_hash(supyoer=nil)
    if supyoer and !SharedLocation.select{|sl| sl.sharing_supyoer_id == id && sl.shared_to_supyoer_id == supyoer.id}.empty?
      return {:id =>self.id, :name =>self.name, :latitude =>self.latitude, :longitude=>self.longitude}
    else
      return {:id =>self.id, :name => self.name}
    end
  end

  # if you person shared your location with 'supyoer', get the object back provided it hasn't expired
  # if it expires we destroy thwe object
  def is_sharing_location_with_supyoer(supyoer)
    shared_location = SharedLocation.first(:sharing_supyoer_id=> id, :shared_to_supyoer_id=>supyoer.id)
    
    return false unless shared_location
    
    if shared_location.is_expired
      shared_location.destroy
      return false
    end

    return true
  end

  def user_token
    return Token.first(:phone_hash=>phone_hash)
  end

end
