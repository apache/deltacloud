ActionController::Routing::Routes.draw do |map|

  map.root :controller=>'root'

  map.resource :api, :controller=>'Api'

  map.resources :flavors, :path_prefix=>'api'
  map.resources :realms, :path_prefix=>'api'
  map.resources :images, :path_prefix=>'api'

  map.resource :instance_states, :path_prefix=>'api',
    :as=>'instance-states',
    :only=>[ :show ]

  map.resources :instances, :path_prefix=>'api',
    :member=>{
      :destroy=>:post,
      :stop=>:post,
      :start=>:post,
      :reboot=>:post,
    }

  map.resource :storage, :path_prefix=>'api' do |s|
    s.resources :volumes, :controller=>'StorageVolumes'
    s.resources :snapshots, :controller=>'StorageSnapshots'
  end

end
