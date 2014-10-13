migration 1, :create_supyoers do
  up do
    create_table :supyoers do
      column :id, Integer, :serial => true
      column :name, DataMapper::Property::String, :length => 255
      column :email, DataMapper::Property::String, :length => 255
      column :password_hash, DataMapper::Property::String, :length => 255
      column :phone_hash, DataMapper::Property::String, :length => 255
      column :last_location_lat, DataMapper::Property::Float
      column :last_location_long, DataMapper::Property::Float
      column :last_location_time, DataMapper::Property::DateTime
    end
  end

  down do
    drop_table :supyoers
  end
end
