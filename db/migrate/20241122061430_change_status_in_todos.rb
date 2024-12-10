class ChangeStatusInTodos < ActiveRecord::Migration[7.0]
  
  def up
    change_column :todos, :status, 'integer USING CAST(status AS integer)', default: 0, null: false
  end

  def down
    change_column :todos, :status, :string
  end
end


