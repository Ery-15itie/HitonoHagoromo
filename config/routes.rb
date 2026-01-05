Rails.application.routes.draw do
  # --- 1. 開発ツール ---
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # --- 2. ユーザー認証 (Devise) ---
  # ビュー側(app/views/devise/...)でランディングページを表示する設定に対応
  devise_for :users

  # ログイン済みユーザーのトップページ
  # クローゼット(items#index)へ案内
  authenticated :user do
    root to: "items#index", as: :authenticated_root
  end

  # ログインしていない人（LP）
  root "pages#landing"

  # --- 3. カレンダー機能 ---
  # URL: /calendar
  # Path: calendar_path
  resource :calendar, only: [:show], controller: 'calendars'

  # --- 4. メイン機能: 着用記録 (ActualOutfit) ---
  resources :actual_outfits do
    # 重複チェック用のルート (Ajaxリクエスト用)
    collection do
      get :check_duplicates
    end
  end

  # --- 5. アイテム管理 ---
  resources :items do
    # アイテム詳細から「これを着た」を登録するためのネスト
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
