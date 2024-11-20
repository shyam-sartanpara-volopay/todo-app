Rails.application.routes.draw do
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
