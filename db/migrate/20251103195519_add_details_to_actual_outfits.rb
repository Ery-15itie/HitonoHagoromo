class AddDetailsToActualOutfits < ActiveRecord::Migration[7.0]
  def change
    add_column :actual_outfits, :time_slot, :string
    add_column :actual_outfits, :impression, :text
  end
end
