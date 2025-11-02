class AllowNullForCategoryIdInItems < ActiveRecord::Migration[7.0]
  def change
    # category_idカラムのNOT NULL制約を解除し、NULLを許可
    change_column_null :items, :category_id, true
  end
end
