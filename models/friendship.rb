class Friendship
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :first_supyoer_id, Integer
  property :second_supyoer_id, Integer
  property :bidirectional, Boolean
end
