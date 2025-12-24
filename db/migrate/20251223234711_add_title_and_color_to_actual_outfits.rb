class AddTitleAndColorToActualOutfits < ActiveRecord::Migration[7.0]
  def change
    add_column :actual_outfits, :title, :string
    add_column :actual_outfits, :color, :string
  end
end
