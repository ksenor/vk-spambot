VkSpambot::Application.routes.draw do
  authenticated :user do
    root :to => 'pages#home'
  end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'pages#home'

  devise_for :users

  resources :users do
    resources :accounts do
      resources :bots
    end

    resources :bots
  end

  devise_scope :user do
    get 'signin',  :to => 'devise/sessions#new'
  end

  match '/contact', :to => 'pages#contact'
  match '/about',   :to => 'pages#about'
  match '/help',    :to => 'pages#help'

  match '/run',               :to => 'bots#run'
  match '/stop',              :to => 'bots#stop'
  match '/run_account_all',   :to => 'bots#run_account_all'
  match '/stop_account_all',  :to => 'bots#stop_account_all'
  match '/run_all',           :to => 'bots#run_all'
  match '/stop_all',          :to => 'bots#stop_all'
  match '/check_status',      :to => 'bots#check_status'

  match '/users/:user_id/accounts/new'      => 'accounts#create',  :via => :post,    :as => 'create_account'
  match '/users/:user_id/accounts/:id/edit' => 'accounts#update',  :via => :put,     :as => 'update_account'
  match '/users/:user_id/accounts/:id'      => 'accounts#destroy', :via => :delete,  :as => 'destroy_account'

  match '/users/:user_id/bots/new'      => 'bots#create',  :via => :post,    :as => 'create_bot'
  match '/users/:user_id/bots/:id/edit' => 'bots#update',  :via => :put,     :as => 'update_bot'
  match '/users/:user_id/bots/:id'      => 'bots#destroy', :via => :delete,  :as => 'destroy_bot'

  match '/users/:user_id/accounts/:account_id/bots/new'      => 'bots#create',  :via => :post,    :as => 'create_user_account_bot'
  match '/users/:user_id/accounts/:account_id/bots/:id/edit' => 'bots#update',  :via => :put,     :as => 'update_user_account_bot'
  match '/users/:user_id/accounts/:account_id/bots/:id'      => 'bots#destroy', :via => :delete,  :as => 'account_destroy_bot'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  #match ':controller(/:action(/:id))(.:format)'
end
