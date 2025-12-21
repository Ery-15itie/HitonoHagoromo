class AddDetailsToContacts < ActiveRecord::Migration[7.0]
  def change
    # default: false, null: false を追加
    add_column :contacts, :is_favorite, :boolean, default: false, null: false
    
    # default: 0, null: false を追加
    add_column :contacts, :group, :integer, default: 0, null: false
  end
end
