Rails.application.routes.draw do
  # Deviseの認証機能のルーティング
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  
  # アイテム管理のCRUDルーティング
  resources :items do
    # アイテムにネストされた着用実績の作成処理のみ。
    # newはトップレベルのパスとして定義し、アイテム詳細画面からIDを渡す形に変更。
    resources :actual_outfits, only: [:create]
  end

  # --- 着用実績記録 (ActualOutfit) のトップレベルルーティング ---
  # index/カレンダー画面からの「記録追加」で必要な new と、destroyを定義
  resources :actual_outfits, only: [:new, :destroy]
  
  # 全ての着用記録を一覧表示するためのトップレベルのルーティング
  # URL: /outfits
  get 'outfits', to: 'actual_outfits#index', as: :actual_outfits

  # --- 着用予定記録 (PlannedOutfit) のルーティング ---
  resources :planned_outfits, only: [:new, :create, :destroy]


  # --- ルートパスの設定 ---
  
  # 認証済みユーザーの場合のルート (アイテム一覧へ)
  authenticated :user do
    root to: "items#index", as: :authenticated_root
  end

  # 未認証ユーザーの場合のルート (カスタムLPへ)
  root to: "home#index"
end
