#!/bin/bash

# Webサーバー起動前のクリーンアップ（サーバーが異常終了した場合のpidファイル削除）
rm -f tmp/pids/server.pid

# Gemを確実にインストールするためにbundle installを実行
echo "Running bundle install to ensure dependencies are loaded..."
bundle install

# GemがPATHに追加されたことを確認するため、新しいシェルを起動し環境を再ロード
# 新しいシェル内でPumaを起動させる
echo "Starting Puma web server via exec..."

# $SHELL の代わりに bash を明示的に使用し、新しい環境でコマンドを実行
/bin/bash -c "exec bundle exec puma -C config/puma.rb"