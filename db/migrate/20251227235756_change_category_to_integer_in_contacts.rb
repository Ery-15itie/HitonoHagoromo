class ChangeCategoryToIntegerInContacts < ActiveRecord::Migration[7.0]
  def up
    # 1. もし古い名前の 'group' カラムが残っていたら削除する
    if column_exists?(:contacts, :group)
      remove_column :contacts, :group
    end

    # 2. もし文字型の 'category' カラムがあったら、一旦削除する
    # (文字から数字への変換エラーを防ぐため、作り直し)
    if column_exists?(:contacts, :category)
      remove_column :contacts, :category
    end

    # 3. 新しく 'integer (数字)' 型で 'category' カラムを作成する
    # default: 0 は 'partner' (大切な人) 
    add_column :contacts, :category, :integer, default: 0
  end

  def down
    remove_column :contacts, :category
    add_column :contacts, :group, :string
  end
end
