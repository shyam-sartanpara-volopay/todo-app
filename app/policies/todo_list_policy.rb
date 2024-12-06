class TodoListPolicy < ApplicationPolicy
  def index?
    user_owns_todo_list? || user_collaborates_on_todo_list?
  end

  def show?

    
    user_owns_todo_list? || user_collaborates_on_todo_list?
  end

  def create?
    true
  end

  def update?
    user_owns_todo_list?
  end

  def destroy?
    user_owns_todo_list?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope
        .joins("LEFT JOIN collaborators ON collaborators.todo_list_id = todo_lists.id")
        .where("todo_lists.user_id = :user_id OR collaborators.user_id = :user_id", user_id: user.id)
        .distinct
    end
  end 

  private

  def user_owns_todo_list?
    @record.user_id == user.id
  end

  def user_collaborates_on_todo_list?
    @record.collaborators.exists?(user_id: user.id)
  end
end
