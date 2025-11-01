class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      # カテゴリ名 (必須、かつユニーク)
      t.string :name, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
