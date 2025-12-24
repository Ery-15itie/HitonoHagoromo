class AddMemoAndRelationsToActualOutfits < ActiveRecord::Migration[7.0]
  def change
    # 1. メモ欄の追加
    add_column :actual_outfits, :memo, :text

    # 2. 服を複数紐付けるための中間テーブル
    create_table :outfit_items do |t|
      t.references :actual_outfit, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.timestamps
    end

    # 3. 人を複数紐付けるための中間テーブル
    create_table :outfit_contacts do |t|
      t.references :actual_outfit, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.timestamps
    end
  end
end
