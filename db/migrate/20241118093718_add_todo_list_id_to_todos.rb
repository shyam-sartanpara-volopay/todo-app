class AddTodoListIdToTodos < ActiveRecord::Migration[7.0]
  def change
    add_column :todos, :todo_list_id, :integer
  end
end
