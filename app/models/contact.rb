class Contact < ApplicationRecord
  belongs_to :user
  
  # --- アソシエーション ---
  has_many :actual_outfit_contacts, dependent: :destroy
  has_many :actual_outfits, through: :actual_outfit_contacts
  has_many :outfit_contacts, dependent: :destroy

  # --- 画像 ---
  has_one_attached :avatar

  # --- ★修正: カテゴリ設定 (Enum) ---
  # 「大切な人(partner)」を削除し、チェックボックスのみで管理するようにします。
  # 残りのカテゴリの番号を 0 から振り直します。
  enum category: {
    family: 0,  # 家族
    friend: 1,  # 友達
    work: 2,    # 仕事
    other: 3    # その他
  }

  # --- バリデーション ---
  validates :name, presence: true, length: { maximum: 50 }
  validate :avatar_validation

  # --- 便利メソッド ---
  def category_label
    # お気に入りの場合は、カテゴリに関係なく「大切な人」と表示する
    return I18n.t("enums.contact.category.partner") if is_favorite?
    
    # それ以外でカテゴリが未設定の場合
    return "未設定" if category.nil?

    # カテゴリ名を返却
    I18n.t("enums.contact.category.#{category}")
  end

  private

  # 画像チェック
  def avatar_validation
    return unless avatar.attached?

    if avatar.blob.byte_size > 5.megabytes
      errors.add(:avatar, "は5MB以下のファイルにしてください")
    end

    if !avatar.content_type.in?(%w[image/jpeg image/png image/webp])
      errors.add(:avatar, "はJPEG, PNG, WebP形式のみ可能です")
    end
  end
end
