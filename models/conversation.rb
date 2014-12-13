class Conversation
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :first_supyoer_id, Integer, :required => true
  property :second_supyoer_id, Integer, :required => true
  property :state, Integer, :default => 0
  property :created_at, DateTime
  property :updated_at, DateTime
  property :last_update_by, Integer

  def self.conversation_between_users(first, second)
    conversation = Conversation.first(:first_supyoer_id=>first.id, :second_supyoer_id=>second.id)
    if conversation
      return conversation
    else
      conversation = Conversation.first(:first_supyoer_id=>second.id, :second_supyoer_id=>first.id)
    end
    return conversation if conversation
    return nil
  end
end
