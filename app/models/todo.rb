class Todo < ApplicationRecord
  belongs_to :todo_list

  # Use enum to define valid statuses
  enum status: { pending: 0, completed: 1, archived: 2 }

  validates :title, presence: true
  validates :status, inclusion: { in: statuses.keys }

  # Toggle the status to the next state
  def toggle_status!
    return false if archived? # Don't allow toggling if the status is archived

    new_status = pending? ? :completed : :archived
    update(status: new_status)
  end

end
