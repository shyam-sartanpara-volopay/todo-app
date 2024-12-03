class ApplicationController < ActionController::API
        include DeviseTokenAuth::Concerns::SetUserByToken
        include Pundit::Authorization
        
        rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
        
        private

        def user_not_authorized
                render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
        end
end