class Contact < ApplicationRecord
  # 連絡先は必ずユーザーに属する
  belongs_to :user
  
  # この連絡先（会った人）に関連する全ての着用実績を持つ (1:多) 
  # 連絡先が削除されたら、関連する着用記録の contact_id を nil にする（着用記録自体は残す）
  has_many :actual_outfits, dependent: :nullify 

  # バリデーション
  validates :name, presence: true, length: { maximum: 50 }
end
