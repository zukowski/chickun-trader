ChickunExchange::Application.routes.draw do
  root :to => 'data#index'

  match 'data/:exchange/:pair/depth' => 'data#depth'
  match 'data/:exchange/:pair/ticker' => 'data#ticker'
end
