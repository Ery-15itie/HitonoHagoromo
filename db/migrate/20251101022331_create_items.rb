class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      # アイテム名 (必須)
      t.string :name, null: false
      # アイテムの説明/メモ (任意)
      t.text :description
      # 価格（任意）
      t.integer :price
      # 色（任意）
      t.string :color
      
      # Userとの関連付け (必須)
      t.references :user, null: false, foreign_key: true
      # Categoryとの関連付け (必須)
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
