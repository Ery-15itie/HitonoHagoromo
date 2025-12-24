class RemoveOldColumnsFromActualOutfits < ActiveRecord::Migration[7.0]
  def change
    # 古い関連付けカラムを削除
    remove_reference :actual_outfits, :item, foreign_key: true
    remove_reference :actual_outfits, :contact, foreign_key: true
  end
end
