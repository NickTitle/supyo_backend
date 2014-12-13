class SharedLocation
  include DataMapper::Resource

    # property <name>, <type>
  property :id, Serial
  property :sharing_supyoer_id,   Integer,  :required => true
  property :shared_to_supyoer_id, Integer,  :required => true
  property :created_at,           DateTime
  property :updated_at,           DateTime
  
  #3 hours from creation this will go away
  property :expires_at,           DateTime, :default  => lambda { |r, p| (Time.now + 10800)}
  property :broadcast,            Boolean,  :default  => false


  def is_expired
    DateTime.now > expires_at
  end
end