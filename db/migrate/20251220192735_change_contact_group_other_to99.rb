class ChangeContactGroupOtherTo99 < ActiveRecord::Migration[7.0]
  def up
    execute 'UPDATE contacts SET "group" = 99 WHERE "group" = 0'
    
    change_column_default :contacts, :group, 99
  end

  def down
    execute 'UPDATE contacts SET "group" = 0 WHERE "group" = 99'
    change_column_default :contacts, :group, 0
  end
end
