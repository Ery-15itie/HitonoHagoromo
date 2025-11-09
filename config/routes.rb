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

  # --- 会う人の管理 (Contact) のルーティング ---
  resources :contacts, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
    # Contact 詳細ページから、その人との着用実績履歴を追えるようにする
    member do
      get 'history'
    end
  end

  # --- 着用実績記録 (ActualOutfit) のカスタムルーティング ---
  # 'outfits' パス全体を ActualOutfitsController に割り当て、名前の競合を回避

  # actual_outfits_path (タイムラインビュー: /outfits)
  get 'outfits', to: 'actual_outfits#timeline', as: :actual_outfits

  # new_actual_outfit_path (/actual_outfits/new)
  get 'actual_outfits/new', to: 'actual_outfits#new', as: :new_actual_outfit
  
  # create (POST /actual_outfits) - ヘルパー名を明示的に指定してフォームと連携
  post 'actual_outfits', to: 'actual_outfits#create', as: :create_actual_outfits

  # destroy (DELETE /actual_outfits/:id)
  delete 'actual_outfits/:id', to: 'actual_outfits#destroy', as: :actual_outfit

  # calendar (/outfits/calendar)
  get 'outfits/calendar', to: 'actual_outfits#index', as: :actual_outfits_calendar
  
  # timeline (/outfits/timeline) (元のパスを維持)
  get 'outfits/timeline', to: 'actual_outfits#timeline', as: :timeline_actual_outfits

  # --- 着用予定記録 (PlannedOutfit) のルーティング ---
  # CRUD処理は全てresourcesで定義
  resources :planned_outfits 


  # --- ルートパスの設定 ---
  
  # 認証済みユーザーの場合のルート (アイテム一覧へ)
  authenticated :user do
    root to: "items#index", as: :authenticated_root
  end

  # 未認証ユーザーの場合のルートを、カスタムLPではなくログインページにリダイレクト
  root to: redirect("/users/sign_in")
end
