class TodosController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_user!  
  before_action :set_todo_list, only: [:index, :create]  
  before_action :set_todo, only: [:update, :destroy, :toggle_status]

  # GET 
  def index
    todos = policy_scope(@todo_list.todos)
    render json: todos
  end

  # POST 
  def create
    @todo = @todo_list.todos.new(todo_params)
    authorize @todo
    if @todo.save
      render json: @todo, status: :created
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT
  def update
    authorize @todo
    if @todo.update(todo_params)
      render json: @todo
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE 
  def destroy
    authorize @todo
    if @todo.destroy
      head :no_content
    else
      render json: { errors: "Could not delete Todo" }, status: :unprocessable_entity
    end
  end

  # PATCH
  def toggle_status
    authorize @todo
    if @todo.toggle_status!
      render json: @todo
    else
      render json: { error: 'Failed to toggle status' }, status: :unprocessable_entity
    end
  end


  private

  
  def set_todo_list
    @todo_list = TodoList.joins(:collaborators)
                       .where("todo_lists.user_id = :user_id OR collaborators.user_id = :user_id", user_id: current_user.id)
                       .find_by(id: params[:todo_list_id])
  render json: { error: "Todo List not found" }, status: :not_found unless @todo_list
  end

  def set_todo
    @todo = policy_scope(Todo).find_by(id: params[:id])
    if @todo.nil?
      render json: { error: "Todo not found" }, status: :not_found
    else
      authorize @todo
    end
  end
  

  def todo_params
    params.require(:todo).permit(:title, :status)
  end
end