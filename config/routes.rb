Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  
  resources :users do
    resources :todo_lists do
      resources :todos do
        member do
          patch :toggle_status
        end
      end
    end
  end
end
