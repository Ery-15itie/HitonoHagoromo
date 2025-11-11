source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Railsのバージョン
gem "rails", "~> 7.0.8"
# PostgreSQLデータベースアダプタ
gem "pg", "~> 1.5"

# --- Webアプリ実行に必要な標準Gem ---
gem "puma", "~> 5.0"
gem "tzinfo-data" # タイムゾーンデータ (Docker環境で必要)

# --- フロントエンド技術 ---
gem "tailwindcss-rails"
gem "dartsass-rails" # Tailwind CSSの依存関係
gem "jsbundling-rails" # JavaScript バンドラー 
gem "turbo-rails"
gem "stimulus-rails"

# --- 認証機能 ---
gem "devise"
# デフォルトのJavaScriptバンドルとアセット管理
gem "propshaft"

# --- 環境別Gem ---

# 開発/テスト環境でのみ使用
group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
end

# 開発環境でのみ使用
group :development do
  gem "letter_opener"
  gem "letter_opener_web"
end

# テスト環境でのみ使用
group :test do
  gem "rspec-rails"
end

# Production環境用：ProductionではPumaを使用
group :production do
end
