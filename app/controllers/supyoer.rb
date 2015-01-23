Supyo::App.controllers :supyoer do
  
  require 'dm-serializer'
  require 'json'

  post :create_user, :csrf_protection => false do
    
    @user_hash  = JSON.parse(request.body.read)

    token_val   = @user_hash["auth_token"]
    auth_token  = AuthToken.first(:name=>token_val)

    puts token_val
    puts auth_token

    unless auth_token && auth_token.is_valid?
    return  {
        :error =>{:token => {"auth token is expired or invalid" => "true"} }
      }.to_json
    end

    auth_token.destroy

    s                   = Supyoer.new
    s.name              = @user_hash["name"]
    s.phone_hash        = Supyoer.hash_val(@user_hash["phone"])
    s.password_hash     = Supyoer.hash_val(@user_hash["password"])

    if s.save
      {
        :success =>{
          :user => s.returned_supyoer_hash,
          :token => Token.first_or_create(:phone_hash => s.phone_hash)
        }
      }.to_json
    else
      {
        :error =>s.errors
      }.to_json
    end
  end  

  post :login, :csrf_protection => false do
    
    @user_hash  = JSON.parse(request.body.read)
    
    token_val   = @user_hash["auth_token"]
    auth_token  = AuthToken.first(:name=>token_val)

    unless auth_token && auth_token.is_valid?
    return  {
        :error =>{:token => {"auth token is expired or invalid" => "true"} }
      }.to_json
    end

    auth_token.destroy

    s = Supyoer.first(:name=>@user_hash['name'], :password_hash=>Supyoer.hash_val(@user_hash["password"]))

    if s
      {
        :success =>{
          :user => s.returned_supyoer_hash,
          :token => Token.first_or_create(:phone_hash => s.phone_hash)
        }
      }.to_json
    else
      return  {
        :error =>{:token => {"invalid user or password" => "true"} }
      }.to_json
    end
  end

  #
  # return Array<[contact id, contact id]>
  #
  post :update_contacts, :csrf_protection => false do
    validate
    request.body.rewind
    @phone_hash_array = JSON.parse(request.body.read)

    @supyoer = Supyoer.get(params[:user_id].to_i)
    new_contacts = @supyoer.generate_contacts_from_phone_hash_array(@phone_hash_array['contacts'])
    if new_contacts
      {
        :success => {:new_contacts => new_contacts}
      }.to_json
    else
      {
        :error =>s.errors
      }.to_json
    end
  end

  post :conversation, :csrf_protection => false do

    validate
    request.body.rewind
    @conversation_hash = JSON.parse(request.body.read)

    c = Conversation.new

    puts @conversation_hash[:recipient]
    @first_supyoer = Supyoer.get(@conversation_hash['id'])
    @second_supyoer = Supyoer.get(@conversation_hash['recipient'])

    c.first_supyoer_id = @first_supyoer.id
    c.second_supyoer_id = @second_supyoer.id
    
    if params[:state]
      c.state = params[:state]
    end

    if c.save
      {
        :success =>{
          :conversation => c
        }
      }.to_json
    else
      {
        :error =>c.errors
      }.to_json
    end
  end

  post :share_location, :csrf_protection => false do
    validate
    location_request = JSON.parse(request.body.read)
    
    unless  
      location_request['latitude']      and
      location_request['longitude']     and
      location_request['sharing_id']    and
      location_request['shared_to_id']
      return { :error =>"Missing location or user info" }.to_json
    end

    sharing_supyoer           = Supyoer.get(location_request['sharing_id'])
    sharing_supyoer.latitude  = location_request['latitude']
    sharing_supyoer.longitude = location_request['longitude']
    sharing_supyoer.broadcast = location_request['broadcast'] if location_request['broadcast']

    unless sharing_supyoer.save
      return { :error =>sharing_supyoer.errors}.to_json
    end

    sl = SharedLocation.new
    
    sl.sharing_supyoer_id   = location_request['sharing_id']
    sl.shared_to_supyoer_id = location_request['shared_to_id'] if location_request['shared_to_id']

    if sl.save
      {
        :success =>{
          :shared_location => sl
        }
      }.to_json
    else
      {
        :error =>sl.errors
      }.to_json
    end
  end

  get :friends do
    validate_get
    @supyoer = Supyoer.get(params[:user_id].to_i)
    content_type :json
    unless @supyoer == nil
      @supyoer.following.map{|f| CompleteSupyoer.supyoer_extended_info(f, @supyoer)}.to_json
    end
  end

  get :check_token do
    validate_get
    content_type :json
    {:success=>"token valid"}.to_json
  end

end
