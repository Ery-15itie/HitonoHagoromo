class AddScheduleDetailsToActualOutfits < ActiveRecord::Migration[7.0]
  def change
    # start_time が無ければ追加
    unless column_exists?(:actual_outfits, :start_time)
      add_column :actual_outfits, :start_time, :time
    end

    # title が無ければ追加
    unless column_exists?(:actual_outfits, :title)
      add_column :actual_outfits, :title, :string
    end

    # color が無ければ追加
    unless column_exists?(:actual_outfits, :color)
      add_column :actual_outfits, :color, :string
    end
  end
end
