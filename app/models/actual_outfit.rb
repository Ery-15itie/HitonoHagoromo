class ActualOutfit < ApplicationRecord
  belongs_to :user

  # --- 関連付け (多対多へ変更) ---
  
  # 服 (Items) との関連
  # 中間テーブル (outfit_items) を通じて複数の item を持つ
  has_many :outfit_items, dependent: :destroy
  has_many :items, through: :outfit_items

  # 会った人 (Contacts) との関連
  # 中間テーブル (outfit_contacts) を通じて複数の contact を持つ
  has_many :outfit_contacts, dependent: :destroy
  has_many :contacts, through: :outfit_contacts

  # 画像 (ActiveStorage)
  has_one_attached :image

  # --- Enum定義 (時間帯) ---
  # UIの表記に合わせてコメントを修正
  enum time_slot: {
    morning: 'morning',       # 朝 (06:00-11:59)
    day: 'day',               # 昼 (12:00-17:59)
    night: 'night',           # 夕方 (18:00-23:59)
    late_night: 'late_night'  # 夜   (00:00-05:59)
  }

  # --- バリデーション ---
  validates :worn_on, presence: true
  validates :time_slot, presence: true

  # ※「メモ」は任意入力なのでバリデーションは不要

end
