class Conversation
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :first_supyoer_id, Integer
  property :second_supyoer_id, Integer
  property :state, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
  property :last_update_by, Integer

end
