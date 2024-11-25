class ChangeStatusColumnTypeInTodos < ActiveRecord::Migration[7.0]
  def up
    # Change the column type to integer with explicit casting using SQL
    execute <<-SQL
      ALTER TABLE todos
      ALTER COLUMN status TYPE integer USING
        CASE status
          WHEN 'pending' THEN 0
          WHEN 'completed' THEN 1
          WHEN 'archived' THEN 2
          ELSE NULL
        END,
      ALTER COLUMN status SET DEFAULT 0;
    SQL
  end

  def down
    # Reverse the migration by changing the column back to string
    execute <<-SQL
      ALTER TABLE todos
      ALTER COLUMN status TYPE string USING status::text;
    SQL
  end
end
