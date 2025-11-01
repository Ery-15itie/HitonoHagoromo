# config/routes.rb

Rails.application.routes.draw do
  # Deviseの認証機能のルーティング
  # controllersオプションを追加し、SessionsとRegistrationsにカスタムコントローラーを指定
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  
  # アイテム管理のCRUDルーティング
  resources :items 
  
  # 認証済みユーザーの場合のルート (アイテム一覧へ)
  authenticated :user do
    root to: "items#index", as: :authenticated_root
  end

  # 未認証ユーザーの場合のルート (カスタムLPへ)
  root to: "home#index"
end
