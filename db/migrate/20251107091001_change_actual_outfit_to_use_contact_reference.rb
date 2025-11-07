class ChangeActualOutfitToUseContactReference < ActiveRecord::Migration[7.0] 
  def change
    # 既存の met_people カラムを削除
    remove_column :actual_outfits, :met_people, :string if column_exists?(:actual_outfits, :met_people)

    # contact_id を追加し、外部キー制約とインデックスを設定
    add_reference :actual_outfits, :contact, null: true, foreign_key: true
  end
end