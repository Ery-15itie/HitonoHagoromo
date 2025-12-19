#!/bin/bash
set -e

# 以前のサーバープロセスが残っていた場合に削除する
# (これがないと "server is already running" エラーで止まる)
rm -f /hitonohagoromo/tmp/pids/server.pid

# コンテナのメインプロセスを実行 (DockerfileのCMD)
exec "$@"