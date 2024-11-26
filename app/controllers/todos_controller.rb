class TodosController < ApplicationController
  before_action :authenticate_user!   # Ensure the user is authenticated via token
  before_action :set_todo_list
  before_action :set_todo, only: [:toggle_status, :update, :destroy]

  # GET /users/:user_id/todo_lists/:todo_list_id/todos
  def index
    @todos = @todo_list.todos
    render json: @todos
  end

  # POST /users/:user_id/todo_lists/:todo_list_id/todos
  def create
    @todo = @todo_list.todos.build(todo_params)
    if @todo.save
      render json: @todo, status: :created
    else
      render json: { error: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /users/:user_id/todo_lists/:todo_list_id/todos/:id/toggle_status
  def toggle_status
    if @todo.toggle_status!
      render json: @todo, status: :ok
    else
      render json: { error: 'Failed to toggle status' }, status: :unprocessable_entity
    end
  end

  # PUT /users/:user_id/todo_lists/:todo_list_id/todos/:id
  def update
    if @todo.update(todo_params)
      render json: @todo
    else
      render json: { error: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /users/:user_id/todo_lists/:todo_list_id/todos/:id
  def destroy
    @todo.destroy
    head :no_content
  end

  private

  # Set the TodoList by user_id and todo_list_id
  def set_todo_list
    @todo_list = TodoList.find_by(id: params[:todo_list_id], user_id: params[:user_id])
    unless @todo_list
      logger.error "Todo list not found: #{params[:todo_list_id]}"
      render json: { error: 'Todo list not found' }, status: :not_found
    end
  end

  # Set the Todo by its id within the todo list
  def set_todo
    @todo = @todo_list.todos.find_by(id: params[:id])
    unless @todo
      logger.error "Todo not found: #{params[:id]}"
      render json: { error: 'Todo not found' }, status: :not_found
    end
  end

  # Permit the necessary parameters for Todo creation and updating
  def todo_params
    params.require(:todo).permit(:title, :status)
  end
end
