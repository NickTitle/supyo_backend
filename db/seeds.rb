@supyoers = []

100.times do
	s = Supyoer.create
	s.name = Faker::Lorem.word+Faker::Number.number(5)
	s.phone_hash = Supyoer.hash_val(Faker::Number.number(10))
	s.password_hash = Supyoer.hash_val(Faker::Lorem.characters((6..12).to_a.sample))

	s.save

	@supyoers << s
end

supyoer_range = (Supyoer.first.id..Supyoer.last.id).to_a

supyoer_range.each do |s|
	(5..25).to_a.sample.times do
		f = Friendship.create
		f.first_supyoer_id = s
		f.second_supyoer_id = supyoer_range.sample
		f.save
	end
end

supyoer_range.each do |s|
	(0..5).to_a.sample.times do
		c = Conversation.create
		c.first_supyoer_id = s
		c.second_supyoer_id = supyoer_range.sample
		c.state = [0,1,2].sample
		c.save
	end
end