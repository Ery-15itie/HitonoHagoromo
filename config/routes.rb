Rails.application.routes.draw do
  # Deviseのルーティングを追加
  # Userモデルに基づき、新規登録、ログイン、ログアウトのパスが自動で生成される
  devise_for :users

  # 認証後のルート設定: ログイン後やサインアップ後の遷移先を設定
  # 認証済みユーザーが / にアクセスした場合、現在は静的ページへ戻る
  # 本格的な機能実装後、/dashboard などに変更予定
  authenticated :user do
    root 'pages#index', as: :authenticated_root
  end

  # 未認証ユーザーが / にアクセスした場合、静的ページを表示
  root "pages#index"
end
