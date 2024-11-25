class TodosController < ApplicationController
  before_action :authenticate_user!  
  before_action :set_todo_list, only: [:index, :create]  
  before_action :set_todo, only: [:update, :destroy, :toggle_status]

  # GET 
  def index
    todos = @todo_list.todos
    render json: todos
  end

  # POST 
  def create
    todo = @todo_list.todos.new(todo_params)
    if todo.save
      render json: todo, status: :created
    else
      render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT
  def update
    if @todo.update(todo_params)
      render json: @todo
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE 
  def destroy
    if @todo.destroy
      head :no_content
    else
      render json: { errors: "Could not delete Todo" }, status: :unprocessable_entity
    end
  end

  # PATCH
  def toggle_status
    if @todo.toggle_status!
      render json: @todo
    else
      render json: { error: 'Failed to toggle status' }, status: :unprocessable_entity
    end
  end


  private

  
  def set_todo_list
    @todo_list = current_user.todo_lists.find_by(id: params[:todo_list_id])
    render json: { error: "Todo List not found" }, status: :not_found unless @todo_list
  end

  def set_todo
    @todo = Todo.find_by(id: params[:id])
    if @todo.nil?
      render json: { error: "Todo not found" }, status: :not_found
    end
  end
  

  def todo_params
    params.require(:todo).permit(:title, :status)
  end
end