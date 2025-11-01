class HomeController < ApplicationController
  # 新規作成するLPのメインアクション
  def index
    # ログイン・新規登録フォームで利用するための空のUserインスタンスを作成
    @user = User.new 
  end
end
