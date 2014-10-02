@supyoers = []

500.times do
	s = Supyoer.create
	s.name = Faker::Name.name
	s.email = Faker::Internet.safe_email(s.name)
	s.phone_hash = Supyoer.hash_val(Faker::Number.number(10))
	s.password_hash = Supyoer.hash_val(Faker::Lorem.characters((6..12).to_a.sample))

	s.save

	@supyoers << s
end

supyoer_range = (Supyoer.first.id..Supyoer.last.id).to_a

Supyoer.each do |s|
	(5..50).to_a.sample.times do
		f = Friendship.create
		f.first_supyoer_id = s.id
		f.second_supyoer_id = supyoer_range.sample
		f.save
	end
end