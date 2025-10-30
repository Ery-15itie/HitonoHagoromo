Rails.application.routes.draw do
  # アプリケーションのルートパス（/）を設定
  # PagesControllerのindexアクションにルーティング
  root to: 'pages#index'

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # 今後の機能（認証など）はここに記述
  # devise_for :users
  # resources :meetings, :closets
end
