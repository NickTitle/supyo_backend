migration 2, :create_friendships do
  up do
    create_table :friendships do
      column :id, Integer, :serial => true
      column :first_supyoer_id, DataMapper::Property::Integer
      column :second_supyoer_id, DataMapper::Property::Integer
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
    end
  end

  down do
    drop_table :friendships
  end
end
