class RemoveForeignKeyFromTodoLists < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :todo_lists, :users
  end
end
