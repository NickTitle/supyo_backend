class AuthToken
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String,   :required => true, :default => lambda{|r,p|Supyoer.hash_val(Faker::Lorem.characters((6..12).to_a.sample))}
  property :created_at, DateTime

  def is_valid?
    one_min_ago = DateTime.now - (1.0/1440)
    if created_at < one_min_ago
      self.destroy
      return false
    else
      return true
    end
  end

end