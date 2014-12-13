# Helper methods defined here can be accessed in any controller or view in the application

module Supyo
  class App
    module SupyoerHelper
        def validate
          halt 401 unless Supyo::Validator.validate_request_for_user(request, params[:user_id], params[:hash])
        end

        def validate_get
          halt 401 unless Supyo::Validator.validate_get_request_for_user(params[:user_id], params[:nonce], params[:hash])
        end
    end

    helpers SupyoerHelper
  end
end
