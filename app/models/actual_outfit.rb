class ActualOutfit < ApplicationRecord
  # --- 関連付け ---
  belongs_to :item # どのアイテムを着用したか
  belongs_to :user # 誰が着用記録を作成したか

  # --- バリデーション ---
  # 着用日 (worn_on) は必須
  validates :worn_on, presence: true
  
  # 着用日が未来の日付でないこと
  validate :worn_on_cannot_be_in_the_future

  # --- カスタムバリデーションメソッド ---
  def worn_on_cannot_be_in_the_future
    if worn_on.present? && worn_on > Date.current
      errors.add(:worn_on, "は未来の日付に設定できません")
    end
  end
end
