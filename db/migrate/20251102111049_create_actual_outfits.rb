class CreateActualOutfits < ActiveRecord::Migration[7.0]
  def change
    create_table :actual_outfits do |t|
      # 着用日。必須とし、インデックスを追加
      t.date :worn_on, null: false, index: true
      # どのアイテムの着用記録か。必須
      t.references :item, null: false, foreign_key: true
      # 誰の記録か。必須
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
