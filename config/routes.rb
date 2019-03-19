Rails.application.routes.draw do
  mount DnsManager::V1 => '/'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
