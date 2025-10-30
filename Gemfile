source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2' # Dockerfileで指定したRubyバージョンと一致させる

# Railsのバージョンを指定
gem "rails", "~> 7.0.8"

# WebサーバーとしてPumaを使用
gem "puma", "~> 5.6"

# データベースとしてPostgreSQLを使用
gem "pg", "~> 1.1"

# 認証機能の実装にDeviseを使用
gem "devise"

# 画像登録機能の実装にActive Storageを使用
gem "image_processing"

# Railsのコアアセットパイプライン機能を提供
gem 'sprockets-rails' 
# Rails 7のデフォルトJavaScript管理機能を提供
gem 'importmap-rails' 

# 開発/テスト環境でのみ使用
group :development, :test do
  # デバッギングツール
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

# 開発環境でのみ使用
group :development do
  # アプリケーションの再起動なしにCSS/JSの変更を反映
  gem "dartsass-rails"
  # サーバー再起動なしでコード変更を反映
  gem "listen", "~> 3.8"
end

# テスト環境でのみ使用
group :test do
  # テスティングフレームワーク
  gem "rspec-rails"
end
