class TodosController < ApplicationController
  before_action :set_todo, only: [:update, :destroy]

  # GET /todos
  def index
    todos = Todo.all
    render json: todos
  end

  # POST /todos
  def create
    todo = Todo.new(todo_params)
    if todo.save
      render json: todo, status: :created
    else
      render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /todos/:id
  def update
    if @todo.update(todo_params)
      render json: @todo
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /todos/:id
  def destroy
    if @todo.destroy
      head :no_content
    else
      render json: { errors: "Could not delete Todo" }, status: :unprocessable_entity
    end
  end

  private

  def set_todo
    @todo = Todo.find_by(id: params[:id])
    render json: { error: "Todo not found" }, status: :not_found unless @todo
  end

  def todo_params
    params.require(:todo).permit(:title, :done)
  end
end
