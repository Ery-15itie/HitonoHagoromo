class ChangeTimeSlotToIntegerInActualOutfits < ActiveRecord::Migration[7.0]
  def up
    # 既存のデータを文字列から数値に変換しながら型変更
    change_column :actual_outfits, :time_slot, :integer, using: "
      CASE time_slot
        WHEN 'morning' THEN 0
        WHEN 'day' THEN 1
        WHEN 'night' THEN 2
        WHEN 'late_night' THEN 3
        ELSE 0
      END
    "
  end

  def down
    change_column :actual_outfits, :time_slot, :string
  end
end
