class Users::RegistrationsController < Devise::RegistrationsController
  # 新規登録ページを表示しようとしたときに実行
  # 認証は/ (root_path) の home#index で行うため、ここではルートにリダイレクト
  def new
    redirect_to root_path and return
  end
end
