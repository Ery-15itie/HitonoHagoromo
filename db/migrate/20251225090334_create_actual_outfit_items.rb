class CreateActualOutfitItems < ActiveRecord::Migration[7.0]
  def change
    # 「テーブルが存在しない場合のみ」作成する
    unless table_exists?(:actual_outfit_items)
      create_table :actual_outfit_items do |t|
        t.references :actual_outfit, null: false, foreign_key: true
        t.references :item, null: false, foreign_key: true

        t.timestamps
      end
    end
  end
end
