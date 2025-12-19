module ApplicationHelper
  # DeviseのフォームをLPなどの別ページ（Deviseコントローラー以外）で使うための設定
  
  # フォームが扱うリソース名（ここでは :user）
  def resource_name
    :user
  end

  # フォームで使う空のユーザーオブジェクトを作成
  def resource
    @resource ||= User.new
  end

  # Deviseのルーティング設定を取得
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
end
