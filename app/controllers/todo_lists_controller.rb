class TodoListsController < ApplicationController

  before_action :authenticate_user!   # Ensure the user is authenticated via token
  before_action :set_user
  before_action :set_todo_list, only: [:show, :update, :destroy]
  

  # GET /users/:user_id/todo_lists
  def index
    @todo_lists = policy_scope(TodoList)
    if @todo_lists.none?
      render json: { error: 'Not Found' }, status: :not_found
    else
      render json: @todo_lists
    end  
    
  end

  # POST /users/:user_id/todo_lists
  def create
    @todo_list = @user.todo_lists.build(todo_list_params)
    if @todo_list.save
      render json: @todo_list, status: :created
    else
      render json: { error: @todo_list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /users/:user_id/todo_lists/:id
  def show
    authorize @todo_list
    render json: @todo_list
    
  end

  # PUT /users/:user_id/todo_lists/:id
  def update
    if @todo_list.update(todo_list_params)
      render json: @todo_list
    else
      render json: { error: @todo_list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /users/:user_id/todo_lists/:id
  def destroy
    @todo_list.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find_by(id: params[:user_id])
    return render json: { error: 'User not found' }, status: :not_found unless @user
  end

  def set_todo_list
    @todo_list = policy_scope(TodoList).find_by(id: params[:id])
    unless @todo_list
    return render json: { error: 'Todo list not found or not accessible' }, status: :not_found 
  end
  end

  def todo_list_params
    params.require(:todo_list).permit(:title)
  end
end
