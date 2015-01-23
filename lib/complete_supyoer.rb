module CompleteSupyoer
  def self.supyoer_extended_info(supyoer, requester)
    #if we're here we already know they're friends, so just retrieve the info about this state
    friendship = Friendship.first(:first_supyoer_id=>requester.id, :second_supyoer_id=>supyoer.id)
    conversation = Conversation.conversation_between_users(supyoer,requester)
    conversation_state = nil
    
    did_update_last = nil
    if conversation
      conversation_state = conversation.state
      did_update_last = (conversation.last_update_by == supyoer.id)
    end

    latitude = nil
    longitude = nil
    if supyoer.is_sharing_location_with_supyoer(requester)
      latitude = supyoer.latitude
      longitude = supyoer.longitude
    end

    return {
      :supyoer => {
        :user_ID                  => supyoer.id,
        :user_name                => supyoer.name,
        :hue                      => supyoer.hue,
        :is_favorite              => friendship.is_favorite,
        :is_receiving_my_location => requester.is_sharing_location_with_supyoer(supyoer),
        :conversation_state       => conversation_state,
        :did_update_last          => did_update_last,
        :latitude                 => latitude,
        :longitude                => longitude
      }
    }
  end
end