class TodoList < ApplicationRecord
  belongs_to :user
  has_many :todos, dependent: :destroy

  validates :title, presence: true
  validates :user_id, presence: true
end