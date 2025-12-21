class Contact < ApplicationRecord
  # --- アソシエーション ---
  # 連絡先は必ずユーザーに属する
  belongs_to :user
  
  # この連絡先（会った人）に関連する全ての着用実績を持つ (1:多) 
  # 連絡先が削除されたら、関連する着用記録の contact_id を nil にする
  has_many :actual_outfits, dependent: :nullify 

  # --- アイコン画像 (ActiveStorage) ---
  has_one_attached :avatar

  # --- グループ分け・タグ (Enum) ---
  # データベースには数字で保存され、Rails上では名前で扱う
  # ★修正: 「その他」を99に変更し、一番下に移動
  enum group: {
    家族: 10, # 家族
    友達: 20, # 友だち
    仕事: 30, # 会社
    学校: 40, # 学校
    その他: 99 # その他 (0から99に変更)
  }

  # --- バリデーション (既存) ---
  validates :name, presence: true, length: { maximum: 50 }

  # --- 便利メソッド ---
  # ビューで日本語のグループ名を表示しやすくするためのメソッド
  def group_label
    I18n.t("enums.contact.group.#{group}", default: group.titleize)
  end
end
