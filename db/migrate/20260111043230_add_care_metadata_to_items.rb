class AddCareMetadataToItems < ActiveRecord::Migration[7.0]
  def change
    # 1. 洗濯頻度目安 (1=毎回, 3=3回に1回など) / デフォルトは「1回（毎回）」
    add_column :items, :wash_frequency, :integer, default: 1, null: false

    # 2. 現在の着用回数 (洗濯したら0にリセット) / デフォルトは0
    add_column :items, :wears_count, :integer, default: 0, null: false

    # 3. 累積洗濯回数 (寿命管理用) / デフォルトは0
    add_column :items, :total_washes, :integer, default: 0, null: false

    # 4. シークレットモード (下着など一覧で隠したいもの用) 
    add_column :items, :is_private, :boolean, default: false, null: false
  end
end
