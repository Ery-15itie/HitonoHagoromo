class ActualOutfit < ApplicationRecord
  # コントローラーから送信される「警告を無視する」フラグを受け取る
  attr_accessor :ignore_duplication 

  # --- 関連付け ---
  belongs_to :item # どのアイテムを着用したか
  belongs_to :user # 誰が着用記録を作成したか
  belongs_to :contact, optional: true 

  # --- バリデーション ---
  # 着用日 (worn_on) は必須
  # (future date validation removed for Planned Outfit compatibility)
  validates :worn_on, presence: true
  
  # 同じユーザーが、同じ着用日、同じ時間帯で、同じアイテムを二重登録できないようにする
  validates :item_id, uniqueness: { scope: [:worn_on, :time_slot, :user_id] }

  # contact_idが指定され、かつ ignore_duplicationがfalseの場合のみ、重複チェックを実行
  validate :check_contact_item_uniqueness, if: -> { contact_id.present? && ignore_duplication != '1' }


  # --- カスタムバリデーションメソッド ---
  
  # 2. 会った人（Contact）とアイテムの重複着用をチェックするカスタムバリデーション
  def check_contact_item_uniqueness
    # contact_idとitem_idが両方存在する場合のみチェック
    return unless contact_id.present? && item_id.present?

    # 同じ user, item_id, contact_id のレコードを検索 (自分自身は除く)
    duplicate_outfit = ActualOutfit.where(
      user_id: user_id,
      item_id: item_id,
      contact_id: contact_id
    ).where.not(id: id).exists?

    if duplicate_outfit
      # ★★★ 修正後のメッセージ ★★★
      errors.add(:base, "警告: この相手に対して、このアイテムの着用記録が既に存在します。重複を避けることを推奨します。")
    end
  end
end
