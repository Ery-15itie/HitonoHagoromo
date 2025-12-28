class CreateActualOutfitContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :actual_outfit_contacts do |t|
      t.references :actual_outfit, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true

      t.timestamps
    end
  end
end
