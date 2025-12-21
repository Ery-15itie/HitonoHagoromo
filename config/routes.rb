Rails.application.routes.draw do
  # --- 1. 開発ツール ---
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # --- 2. ユーザー認証 (Devise) ---
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  # ログイン済みユーザーのトップページ
  authenticated :user do
    root to: "items#index", as: :authenticated_root
  end

  # --- 3. トップページ (LP) ---
  # ログインしていない人（または authenticated にマッチしなかった人）はここ
  root "pages#landing"

  # --- 4. メイン機能: 着用記録 (ActualOutfit) ---
  resources :actual_outfits do
    collection do
      get :timeline
    end
  end

  # --- 5. アイテム管理 ---
  resources :items do
    resources :actual_outfits, only: [:create]
  end

  # --- 6. 会った人管理 ---
  resources :contacts do
    member do
      get :history           # 会った履歴
      patch :toggle_favorite # お気に入り切り替え
    end
  end

  # --- 7. 着用予定 (PlannedOutfit) ---
  resources :planned_outfits

  # --- 8. 静的ページ ---
  get 'terms', to: 'pages#terms', as: :terms
  get 'privacy', to: 'pages#privacy', as: :privacy
end
