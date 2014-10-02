migration 2, :create_friendships do
  up do
    create_table :friendships do
      column :id, Integer, :serial => true
      column :first_supyoer, DataMapper::Property::Supyoer
      column :second_supyoer, DataMapper::Property::Supyoer
      column :state, DataMapper::Property::Integer
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
      column :last_update_by, DataMapper::Property::Supyoer
    end
  end

  down do
    drop_table :friendships
  end
end
