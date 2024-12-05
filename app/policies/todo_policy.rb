class TodoPolicy < ApplicationPolicy

  def index?
    user_owns_todo_list? || user_collaborates_on_todo_list?
  end
  def show?
    user_owns_todo_list? || user_collaborates_on_todo_list?
  end

  def create?
    user == record.todo_list.user || record.todo_list.collaborators.exists?(user: user)
  end

  def update?
    user_owns_todo_list? || user_collaborates_on_todo_list?
  end

  def destroy?
    user_owns_todo_list? 
  end

  class Scope < Scope
    def resolve
      scope.joins(:todo_list).where(
        "todo_lists.user_id = :user_id OR todo_lists.id IN (:collaborated_todo_lists_ids)",
        user_id: user.id,
        collaborated_todo_lists_ids: Collaborator.where(user_id: user.id).pluck(:todo_list_id)
      )
    end
  end

  private

  def user_owns_todo_list?
    @record.todo_list.user_id == user.id
  end

  def user_collaborates_on_todo_list?
    @record.todo_list.collaborators.exists?(user_id: user.id)
  end
end
