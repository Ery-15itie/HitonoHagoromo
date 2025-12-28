FactoryBot.define do
  factory :contact do
    association :user
    
    # Fakerを使う場合 (GemfileにFakerが入っている前提)
    name { Faker::Name.name }
    
    memo { "テスト用のメモ" }
    
    # デフォルト値 (is_favoriteは基本false)
    is_favorite { false }

    # カラム名は 'category'
    # 値は日本語(:友達)ではなく、モデルのEnum定義に合わせた英語(:friend)
    category { :friend } 

    # --- カテゴリ別のバリエーション ---
    trait :family do
      category { :family }
    end

    trait :work do
      category { :work }
    end

    trait :other do
      category { :other }
    end

    # --- 「大切な人」設定のバリエーション ---
    # カテゴリはそのままで、お気に入りフラグだけ立てる
    trait :important do
      is_favorite { true }
    end
    
    # --- 画像ありのバリエーション (テストで画像表示を確認時用) ---
    trait :with_avatar do
      after(:build) do |contact|
        # テスト用の画像パス 
        image_path = Rails.root.join('spec/fixtures/files/test_image.png')
        if File.exist?(image_path)
          contact.avatar.attach(io: File.open(image_path), filename: 'test_image.png', content_type: 'image/png')
        end
      end
    end
  end
end
