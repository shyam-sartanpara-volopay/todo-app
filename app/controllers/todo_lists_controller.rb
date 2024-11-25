class TodoListsController < ApplicationController
  before_action :authenticate_user! 
  before_action :set_todo_list, only: [:show, :update, :destroy] 

  # GET
  def index
    todo_lists = current_user.todo_lists
    render json: todo_lists
  end

  # GET
  def show
    if @todo_list
      render json: @todo_list
    else
      render json: { error: 'Todo List not found' }, status: :not_found
    end
  end

  # POST
  def create
    todo_list = current_user.todo_lists.build(todo_list_params)
    if todo_list.save
      render json: todo_list, status: :created
    else
      render json: todo_list.errors, status: :unprocessable_entity
    end
  end

  # PUT
  def update
    if @todo_list&.update(todo_list_params)
      render json: @todo_list
    else
      render json: { error: 'Unable to update Todo List' }, status: :unprocessable_entity
    end
  end

  # DELETE
  def destroy
    if @todo_list&.destroy
      render json: { message: 'Todo List deleted successfully' }, status: :ok
    else
      render json: { error: 'Unable to delete Todo List' }, status: :unprocessable_entity
    end
  end

  private

  def todo_list_params
    params.require(:todo_list).permit(:title)
  end

  def set_todo_list
    @todo_list = current_user.todo_lists.find_by(id: params[:id])
  end
end
