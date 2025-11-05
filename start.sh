#!/bin/bash

# データベースの準備ができるまで待機
echo "Waiting for PostgreSQL to start..."
while ! pg_isready -h db -U postgres; do
  sleep 1
done
echo "PostgreSQL started successfully."

# Webサーバー起動前のクリーンアップ
rm -f tmp/pids/server.pid

# Ruby Gemのインストールと更新
echo "Running bundle install..."
bundle install

# JavaScriptパッケージのインストール
echo "Running yarn install..."
yarn install

# データベースが存在しない場合は作成し、マイグレーションを実行
echo "Checking and running migrations..."
bundle exec rails db:create || true
bundle exec rails db:migrate

# Webサーバー(Puma)を起動
echo "Starting Puma web server..."
exec bundle exec puma -C config/puma.rb -b 0.0.0.0