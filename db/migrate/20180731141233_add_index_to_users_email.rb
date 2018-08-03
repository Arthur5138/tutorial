class AddIndexToUsersEmail < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :email, unique: true #uniqueをつけてDBレベルでのemailの一意性を確保&indexを追加して検索効率をup
  end
end
