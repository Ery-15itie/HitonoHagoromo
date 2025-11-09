class ActualOutfit < ApplicationRecord
  # --- 関連付け ---
  belongs_to :item # どのアイテムを着用したか
  belongs_to :user # 誰が着用記録を作成したか
  # 会った人 (Contact) との関連付け。contact_id は任意のため optional: true
  belongs_to :contact, optional: true 

  # --- バリデーション ---
  # 着用日 (worn_on) は必須
  validates :worn_on, presence: true
  
  # 着用日が未来の日付でないこと
  validate :worn_on_cannot_be_in_the_future

  # 同じユーザーが、同じ着用日、同じ時間帯で、同じアイテムを二重登録できないようにする
  validates :item_id, uniqueness: { scope: [:worn_on, :time_slot, :user_id] }

  # contact_idが指定されている場合のみ、重複チェックを実行
  validate :check_contact_item_uniqueness, if: -> { contact_id.present? }


  # --- カスタムバリデーションメソッド ---

  # 1. 着用日が未来の日付でないことのチェック
  def worn_on_cannot_be_in_the_future
    if worn_on.present? && worn_on > Date.current
      errors.add(:worn_on, "は未来の日付に設定できません")
    end
  end
  
  # 2. 会った人（Contact）とアイテムの重複着用をチェックするカスタムバリデーション
  def check_contact_item_uniqueness
    # contact_idとitem_idが両方存在する場合のみチェック
    return unless contact_id.present? && item_id.present?

    # 同じ user, item_id, contact_id のレコードを検索 (自分自身は除く)
    duplicate_outfit = ActualOutfit.where(
      user_id: user_id,
      item_id: item_id,
      contact_id: contact_id
    ).where.not(id: id).exists? # .where.not(id: id) は編集時のチェックで重要

    if duplicate_outfit
      # 重複が確認された場合、エラーメッセージを追加
      errors.add(:item_id, "は、この人に対して既に着用記録があります。同じアイテムの再度着用です！！")
    end
  end
end
