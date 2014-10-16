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

  # get '/example' do
  #   'Hello world!'
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
  post :update_contacts, :with => :id,  :csrf_protection => false do
    @phone_hash_array = JSON.parse(request.body.read)

    @supyoer = Supyoer.get(params[:id].to_i)
    @supyoer.generate_contacts_from_phone_hash_array(@phone_hash_array)
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

  post :conversation, :csrf_protection => false do

    c = Conversation.new

    puts Supyoer.get(params[:id])
    puts params
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

end
