class Collaborator < ApplicationRecord
  belongs_to :user
  belongs_to :todo_list
  validates :user_id, uniqueness: { scope: :todo_list_id, message: "is already a collaborator for this todo list" }


end
