class AddStatusToTodos < ActiveRecord::Migration[7.0]
  def change
    add_column :todos, :status, :string
  end
end
