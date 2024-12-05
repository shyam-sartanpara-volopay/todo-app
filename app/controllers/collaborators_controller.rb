class CollaboratorsController < ApplicationController
  before_action :authenticate_user! 
  before_action :set_user 
  before_action :set_todo_list, only: [:create,:index,:destroy]


  #GET
  def index
    @collaborator = @todo_list.collaborators
    authorize @collaborator
    render json: @collaborator, status: :ok
  end
  
  #POST
  def create
    @collaborator = @todo_list.collaborators.build(collab_params)
    authorize @collaborator
    if @collaborator.save
      render json: @collaborator, status: :created
    else
      render json: { error: @collaborator.errors.full_messages }, status: :unprocessable_entity
    end
  end
  

  #DELETE
  def destroy
    @collaborator = @todo_list.collaborators.find_by(id: params[:id])
    if @collaborator
      authorize @collaborator
      @collaborator.destroy
      render json: { message: 'Collaborator removed successfully' }, status: :ok
    else
      render json: { error: 'Collaborator not found' }, status: :not_found
    end
  end



  private
  def set_user
    @user = User.find_by(id: params[:user_id])
    return render json: { error: 'User not found' }, status: :not_found unless @user
  end

  def set_todo_list
    @todo_list = @user.todo_lists.find_by(id: params[:todo_list_id])
    return render json: { error: 'Todo list not found' }, status: :not_found unless @todo_list
  end

  def collab_params
    params.require(:collaborator).permit(:user_id)
  end
end
