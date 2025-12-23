FactoryBot.define do
  factory :contact do
    association :user
    name { Faker::Name.name }
    memo { "テスト用のメモ" }
    
    # モデルの定義に合わせて「友達」にする
    group { :友達 } 

    trait :other do
      group { :その他 }
    end
    
    trait :family do
      group { :家族 }
    end
  end
end
