class RemoveDoneFromTodos < ActiveRecord::Migration[7.0]
  def change
    remove_column :todos, :done, :boolean
  end
end
