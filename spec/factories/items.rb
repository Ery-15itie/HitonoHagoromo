# spec/factories/items.rb
FactoryBot.define do
  factory :item do
    association :user
    
    name { "お気に入りの白Tシャツ" }
    price { 3000 }
    color { "ホワイト" }
    description { "着心地が良い" }

    # 画像ありのパターン
    trait :with_image do
      after(:build) do |item|
        image_path = Rails.root.join('spec/fixtures/files/test_image.png')
        if File.exist?(image_path)
          item.image.attach(io: File.open(image_path), filename: 'test_image.png', content_type: 'image/png')
        end
      end
    end
  end
end
