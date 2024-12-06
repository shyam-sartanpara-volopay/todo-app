class AddUniqueIndexToCollaborators < ActiveRecord::Migration[7.0]
  def change
    duplicates = Collaborator.group(:user_id, :todo_list_id).having('COUNT(*) > 1').pluck(:user_id, :todo_list_id)
    
    duplicates.each do |user_id, todo_list_id|
      Collaborator.where(user_id: user_id, todo_list_id: todo_list_id).order(:id).offset(1).destroy_all
    end
    
    add_index :collaborators, [:user_id, :todo_list_id], unique: true
  end
end
