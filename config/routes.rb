Scaphandrier::Application.routes.draw do
  namespace :admin do
    basic_admin_scaffolds = [:users]
    basic_admin_scaffolds.each { |a|
      resources(a) { as_routes }
    }
    resources :users do
      member do
        post :impersonate
      end
      collection do
        post :deimpersonate
      end
    end
  end

  # Uncomment to turn on the landing page with email collect for the private release.
  #root :to => 'visitors#new'
  root :to => 'home#index'

  resources :events, :only => :index
  resources :tags
  resources :splashes do
    resources :comments
  end

  resources :tracks do
    resources :splashes

    collection do
      get :top
    end
  end

  resources :undiscovered_tracks do
    member do
      get :download
    end
  end
  match 'undiscovered_tracks/:id/download' => 'undiscovered_tracks#download',
        :as => :download_track

  resource :visitor

  match 'home' => 'home#index', :as =>'home'
  match 'dashboard' => 'home#index', :as => 'dashboard'
  match 'home/events' => 'home#events'
  match 'home/event_updates' => 'home#event_updates'

  get "home/index"

  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" } do
    get '/users/auth/:provider' => 'omniauth_callbacks#passthru'
    get '/users/exists' => 'users#exists'
  end

  resources :notifications do
    put 'reset_read', :on => :collection
  end
  match '/profile' => 'users#show'
  resources :users do
    get 'avatar'
    get 'crop'

    member do
      get :events
      get :event_updates
    end

    collection do
      get :top
    end
  end
  resources :relationships, :only => [:create, :destroy] do
    collection do
      get 'following'
      get 'followers'
    end
  end

  match 'search'        => 'searches#create', :as => 'search'
  match 'search/expand' => 'searches#expand', :as => 'expand_search'

  match '/:id' => 'users#show', :as => 'user_slug'

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

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
