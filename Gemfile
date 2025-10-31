source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

require_relative "boot"

# Railsのバージョン
gem "rails", "~> 7.0.8"
# PostgreSQLデータベースアダプタ
gem "pg", "~> 1.5"

# Tailwind CSS、Hotwire (Turbo and Stimulus)
gem "sprockets-rails", "~> 3.4"
gem "tailwindcss-rails"
gem "turbo-rails"
gem "stimulus-rails"

# 認証機能
gem "devise"

# API経由でLLMを呼び出すためのgem 
# gem 'google-genai', '~> 0.1'

# デフォルトのJavaScriptバンドルとアセット管理
gem "propshaft"

# デバッグと開発
group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
end

group :development do
  # web-consoleはDocker環境では使えないため削除、またはコメントアウト
  # gem "web-console" 
end

group :test do
  gem "rspec-rails"
end

# Production環境用：PostgreSQLを使用し、RailsサーバーとしてPumaを導入
group :production do
  gem "puma"
  # 本番環境ではPostgreSQLのみを使用するため、sqlite3を外し、pgをproductionグループに含める
end

# 開発用データベース（Docker環境で簡単に動かすためSQLite3を使用）
group :development do
  gem "sqlite3", "~> 1.4"
end
