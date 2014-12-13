class Friendship
  include DataMapper::Resource

  property :id,                  Serial
  property :first_supyoer_id,   Integer,  :required => true
  property :second_supyoer_id,  Integer,  :required => true,
                                          :unique   => :first_supyoer_id
  property :is_favorite,        Boolean,  :default  => false
  
end