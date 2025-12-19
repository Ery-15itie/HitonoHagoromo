# ベースイメージ
FROM ruby:3.2.2

# 必要なパッケージのインストール
# build-essential: コンパイル用
# libpq-dev: PostgreSQL接続用
# libvips: 画像処理用 (ActiveStorageで必須)
# curl: Node.jsインストーラ取得用
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  postgresql-client \
  libvips \
  curl \
  && rm -rf /var/lib/apt/lists/*

# --- Node.js と Yarn のインストール ---
# Tailwind CSS や JSバンドリングに必須
ARG NODE_VERSION=18
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn

# --- 環境設定 ---
ENV BUNDLE_PATH /usr/local/bundle
ENV PATH $BUNDLE_PATH/bin:$PATH

# 作業ディレクトリ
WORKDIR /hitonohagoromo

# Gemfileコピー & インストール
COPY Gemfile /hitonohagoromo/Gemfile
COPY Gemfile.lock /hitonohagoromo/Gemfile.lock
RUN bundle install --jobs 4 --retry 3

# アプリケーションコードをコピー
COPY . /hitonohagoromo

# エントリーポイント（サーバー起動前の準備スクリプト）の設定
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# ポート開放
EXPOSE 3000

# デフォルトコマンド (tailwindcssのビルドも行うため bin/dev が理想ですが、まずは安定起動のため rails s)
CMD ["rails", "server", "-b", "0.0.0.0"]