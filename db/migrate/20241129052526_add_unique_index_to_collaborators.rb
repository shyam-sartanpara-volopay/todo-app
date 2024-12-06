class AddUniqueIndexToCollaborators < ActiveRecord::Migration[7.0]
  def change
    duplicates = Collaborator.group(:user_id, :todo_list_id)
    .having('COUNT(*) > 1')
    .pluck(:user_id, :todo_list_id)

  duplicates.each do |user_id, todo_list_id|
  # Keep only the first record and delete the rest
  Collaborator.where(user_id: user_id, todo_list_id: todo_list_id)
  .order(:id)
  .offset(1) # Skip the first record
  .destroy_all
  end

# Step 2: Add the unique index
add_index :collaborators, [:user_id, :todo_list_id], unique: true
  end
end
