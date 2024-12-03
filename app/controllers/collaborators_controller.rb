class CollaboratorsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_todo_list, only: [:create, :index , :destroy] 

  def index
    collaborator = @todo_list.collaborators
    render json: collaborator, status: :ok
  end

  def create
    collaborator = @todo_list.collaborators.build(collab_params)
    if collaborator.save
      render json: collaborator, status: :created
    else
      render json: collaborator.errors, status: :unprocessable_entity
    end 
  end

  def destroy
    collaborator = @todo_list.collaborators.find_by(id: params[:id])
    if collaborator
      collaborator.destroy
      render json: { message: 'Collaborator removed successfully' }, status: :ok
    else
      render json: { error: 'Collaborator not found' }, status: :not_found
    end
  end

  private

  def collab_params
    params.require(:collaborator).permit(:user_id)
  end

  def set_todo_list
    @todo_list = current_user.todo_lists.find_by(id: params[:todo_list_id])
  unless @todo_list
    render json: { error: 'Todo list not found or not accessible' }, status: :not_found
  end
  end

end
