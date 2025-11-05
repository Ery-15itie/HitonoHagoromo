# 使用するRubyのベースイメージを指定
FROM ruby:3.2.2

# 必要なパッケージのインストール 
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  postgresql-client \
  # aptキャッシュを削除してイメージサイズを削減
  && rm -rf /var/lib/apt/lists/*

# --- Gemのインストールパス設定 ---
# Gemのインストール先をコンテナ内の固定パスに設定
ENV BUNDLE_PATH /usr/local/bundle
# 実行バイナリのパスをPATHに追加
ENV PATH $BUNDLE_PATH/bin:$PATH

# 作業ディレクトリの設定
WORKDIR /hitonohagoromo

# Gemfileをコピー
COPY Gemfile /hitonohagoromo/Gemfile

# Gemをインストール (Gemをイメージに焼き付ける)
RUN bundle install --jobs 4 --retry 3

# アプリケーションコードをコピー
COPY . /hitonohagoromo