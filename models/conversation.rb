class Conversation
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :first_supyoer_id,     Integer,  :required => true
  property :second_supyoer_id,    Integer,  :required => true
  property :state,                Integer,  :default  => 0
  property :created_at,           DateTime
  property :updated_at,           DateTime
  property :last_update_by,       Integer

  validates_with_method :check_existence

  def check_existence
    if Conversation.conversation_between_users(Supyoer.get(self.first_supyoer_id), Supyoer.get(self.second_supyoer_id))
      return [ false, "Conversation already exists" ]
    end
    return true
  end

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
