class Todo < ApplicationRecord
  belongs_to :todo_list

  enum status: { pending: 0, completed: 1, archived: 2 }

  validates :title, presence: true
  validates :status, inclusion: { in: statuses.keys }
  
  def toggle_status!
    return false if archived? 
    new_status = pending? ? :completed : :archived
    update(status: new_status)
  end

end
