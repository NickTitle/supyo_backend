Supyo::App.controllers :supyoer do
  
  require 'dm-serializer'
  require 'json'

  before do
    unless Supyo::Validator.validate_request(params[:nonce], params[:hash])
      halt 401
    end
  end

  # get :index, :map => '/foo/bar' do
  #   session[:foo] = 'bar'
  #   render 'index'
  # end

  # get :sample, :map => '/sample/url', :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   'Maps to url '/foo/#{params[:id]}''
  # end

  post :create_user, :csrf_protection => false do
    @user_hash            = JSON.parse(request.body.read)

    s                   = Supyoer.new
    s.name              = @user_hash["name"]
    s.email             = @user_hash["email"]
    s.phone_hash        = Supyoer.hash_val(@user_hash["phone"])
    s.password_hash     = Supyoer.hash_val(@user_hash["password"])

    if s.save
      {
        :success =>{
          :user => s
        }
      }.to_json
    else
      {
        :error =>s.errors
      }.to_json
    end
  end  

  #
  # return Array<[contact id, contact id]>
  #
  post :update_contacts, :csrf_protection => false do
    @phone_hash_array = JSON.parse(request.body.read)

    @supyoer = Supyoer.get(@phone_hash_array['id'].to_i)
    @supyoer.generate_contacts_from_phone_hash_array(@phone_hash_array['contacts'])

    @supyoer.following.map{|f| f.returned_supyoer_hash }.to_json
  end

  post :conversation, :csrf_protection => false do

    c = Conversation.new

    @first_supyoer = Supyoer.get(params[:id])
    @second_supyoer = Supyoer.get(params[:recipient])

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

  get :contact_list, :with =>:id do
    @supyoer = Supyoer.get(params[:id].to_i)
    content_type :json
    unless @supyoer == nil
      @supyoer.following.map{|f| f.returned_supyoer_hash }.to_json
    end
  end
  
  get :conversations, :with => :id do
    @supyoer = Supyoer.get(params[:id].to_i)
    content_type :json
    unless @supyoer == nil
      @supyoer.conversations.select{|c| c.created_at > DateTime.now-2}.to_json
    end
  end

  get :locations, :with => :id do
    @supyoer = Supyoer.get(params[:id].to_i)
    puts @supyoer
    content_type :json
    unless @supyoer == nil
      sharing_contact_ids = SharedLocation.select{|s| s.shared_to_supyoer_id == @supyoer.id}.map{|sl| sl.sharing_supyoer_id}
      found_contacts = Supyoer.select{|s| sharing_contact_ids.include?(s.id)}
      found_contacts.map{|f| f.returned_supyoer_hash(@supyoer)}.to_json
    end
  end

end
