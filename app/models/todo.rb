class Todo < ApplicationRecord
  belongs_to :todo_list

  # Valid statuses
  STATUSES = %w[pending completed archived].freeze

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }

  # Toggle the status to the next state
  def toggle_status!
    current_index = STATUSES.index(status)
    next_index = (current_index + 1) % STATUSES.size
    update!(status: STATUSES[next_index])
  end
end
