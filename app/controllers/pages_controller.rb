# 静的ページ（トップページなど）を扱うためのコントローラー
class PagesController < ApplicationController
  # 認証機能が未実装のため、一時的にDeviseの認証をスキップ
  # 認証実装後、必要に応じて修正
  # skip_before_action :authenticate_user!, only: [:index]

  # ルートパス（/）でアクセスされるトップページ
  def index
    # ここではビューを表示する以外のロジックは不要
  end
end
