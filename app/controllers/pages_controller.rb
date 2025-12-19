class PagesController < ApplicationController
  # ログインしていなくても、LP、利用規約、プライバシーポリシーは見れるようにする
  skip_before_action :authenticate_user!, only: [:landing, :terms, :privacy]

  def landing
    # LP表示アクション
  end

  def terms
  end

  def privacy
  end
end
