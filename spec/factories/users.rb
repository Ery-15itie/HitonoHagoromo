FactoryBot.define do
  factory :user do
    # Fakerを使ってランダムなメアドを生成
    email { Faker::Internet.unique.email }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
