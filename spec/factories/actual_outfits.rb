# spec/factories/actual_outfits.rb
FactoryBot.define do
  factory :actual_outfit do
    association :user
    
    worn_on { Date.today }
    time_slot { :morning } # Enumのキー指定
    title { "休日のデート" }
    memo { "とても楽しかった" }

    # --- 関連データの作成 (多対多) ---
    trait :with_details do
      transient do
        contacts_count { 1 }
        items_count { 1 }
      end

      after(:build) do |actual_outfit, evaluator|
        # 関連する「人」を作成して紐付け
        actual_outfit.contacts << build_list(:contact, evaluator.contacts_count, user: actual_outfit.user)
        # 関連する「アイテム」を作成して紐付け
        actual_outfit.items << build_list(:item, evaluator.items_count, user: actual_outfit.user)
      end
    end
    
    # 画像あり
    trait :with_image do
      after(:build) do |outfit|
        image_path = Rails.root.join('spec/fixtures/files/test_image.png')
        if File.exist?(image_path)
          outfit.image.attach(io: File.open(image_path), filename: 'test_image.png', content_type: 'image/png')
        end
      end
    end
  end
end
