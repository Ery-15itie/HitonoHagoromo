Rails.application.routes.draw do
  # Deviseの認証機能のルーティング
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  
  # アイテム管理のCRUDルーティング
  resources :items do
    # アイテムにネストされた着用実績の作成処理
    # :actual_outfits の create アクションのみをネストで定義
    resources :actual_outfits, only: [:create]
  end

  # --- 着用実績記録 (ActualOutfit) のカスタムルーティング ---
  # 'outfits' パス全体を ActualOutfitsController に割り当て、名前の競合を回避

  # 1. actual_outfits_path (タイムラインビュー: /outfits)
  get 'outfits', to: 'actual_outfits#timeline', as: :actual_outfits

  # 2. new_actual_outfit_path (/actual_outfits/new)
  get 'actual_outfits/new', to: 'actual_outfits#new', as: :new_actual_outfit
  
  # 3. create (POST /actual_outfits)
  post 'actual_outfits', to: 'actual_outfits#create'

  # 4. destroy (DELETE /actual_outfits/:id)
  delete 'actual_outfits/:id', to: 'actual_outfits#destroy', as: :actual_outfit

  # 5. calendar (/outfits/calendar)
  get 'outfits/calendar', to: 'actual_outfits#index', as: :actual_outfits_calendar
  
  # 6. timeline (/outfits/timeline) (元のパスを維持)
  get 'outfits/timeline', to: 'actual_outfits#timeline', as: :timeline_actual_outfits

  # --- 着用予定記録 (PlannedOutfit) のルーティング ---
  # CRUD処理は全てresourcesで定義
  resources :planned_outfits 


  # --- ルートパスの設定 ---
  
  # 認証済みユーザーの場合のルート (アイテム一覧へ)
  authenticated :user do
    root to: "items#index", as: :authenticated_root
  end

  # 未認証ユーザーの場合のルート (カスタムLPへ)
  root to: "home#index"
end
