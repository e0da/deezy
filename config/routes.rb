ActionController::Routing::Routes.draw do |map|
  map.resources :hosts

  map.root :controller => 'hosts'

  map.dhcpd_conf_url '/dhcpd.conf', :controller => 'hosts', :action => 'dhcpd_conf', :method => :get

  map.dhcpd_conf_url '/freeips.json', :controller => 'hosts', :action => 'free_ips', :method => :get

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

end
