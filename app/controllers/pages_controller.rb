class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:landing, :terms, :privacy]

  # ルートパス用(既存のindex)
  def index
    redirect_to authenticated_root_path if user_signed_in?
  end

  # ランディングページ
  def landing
    redirect_to authenticated_root_path if user_signed_in?
  end

  def terms
    # 利用規約ページ
  end

  def privacy
    # プライバシーポリシーページ
  end
end
