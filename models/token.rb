class Token
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String,   :required => true, :default => lambda{|r,p|Supyoer.hash_val(Faker::Lorem.characters((6..12).to_a.sample))}
  property :phone_hash, String,   :required => true
  property :created_at, DateTime
  property :expires_at, DateTime, :default  => lambda{|r,p|DateTime.now+1}

end