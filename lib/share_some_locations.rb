module Supyo
  def self.share_some_locations
    sample_set = Supyoer.all.sample(50)
    sample_set.sample(20).each do |s|
      
      s.latitude    = (rand()+rand(180)-90).round(8)
      s.longitude   = (rand()+rand(180)-90).round(8)
      s.save

      sl = SharedLocation.new
      sl.sharing_supyoer_id   = s.id
      sl.shared_to_supyoer_id = sample_set.sample.id
      
      while sl.shared_to_supyoer_id == s.id
        sl.shared_to_supyoer_id = sample_set.sample.id
      end

      sl.save
    end
  end
end