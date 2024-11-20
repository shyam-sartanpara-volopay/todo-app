class TodosController < ApplicationController
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
    @todo.toggle_status!
    render json: @todo
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
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

  def set_todo_list
    @todo_list = TodoList.find_by(id: params[:todo_list_id], user_id: params[:user_id])
    return render json: { error: 'Todo list not found' }, status: :not_found unless @todo_list
  end

  def set_todo
    @todo = @todo_list.todos.find_by(id: params[:id])
    return render json: { error: 'Todo not found' }, status: :not_found unless @todo
  end

  def todo_params
    params.require(:todo).permit(:title, :status)
  end
end
