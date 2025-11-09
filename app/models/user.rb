class User < ApplicationRecord
  # --- Devise モジュール ---
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # ユーザーは複数のアイテムを持つ (1:多)
  has_many :items, dependent: :destroy
  
  # ユーザーは複数の着用記録を持つ (1:多)
  has_many :actual_outfits, dependent: :destroy

  # ユーザーは複数の会う人を持つ (1:多) 
  has_many :contacts, dependent: :destroy 
end
