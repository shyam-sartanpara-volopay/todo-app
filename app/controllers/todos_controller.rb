class TodosController < ApplicationController

  before_action :authenticate_user!   # Ensure the user is authenticated via token
  before_action :set_todo_list
  before_action :set_todo, only: [:toggle_status, :update, :destroy, :create]

  # GET /users/:user_id/todo_lists/:todo_list_id/todos
  def index
    @todo = @todo_list.todos
    if @todo.none?
      render json: { error: 'Not Found' }, status: :not_found
    else
      render json: @todo
    end  
  
  end

  # POST /users/:user_id/todo_lists/:todo_list_id/todos
  def create
    @todo_list = TodoList.find_by(id: params[:todo_list_id])
    unless @todo_list
      Rails.logger.debug "TodoList not found with id: #{params[:todo_list_id]}"
      return render json: { error: "Todo List not found" }, status: :not_found
    end
  
    @todo = @todo_list.todos.build(todo_params)
    Rails.logger.debug "Attempting to create Todo: #{todo_params.inspect}"
    authorize @todo
  
    if @todo.save
      render json: @todo, status: :created
    else
      render json: { error: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  
  

  # PATCH /users/:user_id/todo_lists/:todo_list_id/todos/:id/toggle_status
  def toggle_status
    authorize @todo
    if @todo.toggle_status!
      render json: @todo, status: :ok
    else
      render json: { error: 'Failed to toggle status' }, status: :unprocessable_entity
    end
  end

  # PUT /users/:user_id/todo_lists/:todo_list_id/todos/:id
  def update
    @todo_list = TodoList.find_by(id: params[:todo_list_id])
    unless @todo_list
      Rails.logger.debug "TodoList not found with id: #{params[:todo_list_id]}"
      return render json: { error: "Todo List not found" }, status: :not_found
    end
  
    @todo = @todo_list.todos.find_by(id: params[:id])
    unless @todo
      Rails.logger.debug "Todo not found with id: #{params[:id]}"
      return render json: { error: "Todo not found" }, status: :not_found
    end
  
    authorize @todo
    if @todo.update(todo_params)
      render json: @todo, status: :ok
    else
      render json: { error: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # DELETE /users/:user_id/todo_lists/:todo_list_id/todos/:id
  def destroy
    @todo = Todo.find_by(id: params[:id], todo_list_id: params[:todo_list_id])
  
    # Ensure authorization before proceeding
    authorize @todo # This checks if the user is authorized to delete this todo
  
    if @todo
      @todo.destroy
      head :no_content # Responds with status 204 for successful deletion
    else
      render json: { error: "Todo not found" }, status: :not_found
    end
  rescue Pundit::NotAuthorizedError
    render json: { error: "You are not authorized to perform this action" }, status: :forbidden
  end
  

  private

  # Set the TodoList by user_id and todo_list_id
  def set_todo_list
    # Fetch the TodoList owned by the user or where the user is a collaborator
    @todo_list = policy_scope(TodoList).find_by(id: params[:todo_list_id])
  
    render json: { error: "Todo List not found" }, status: :not_found unless @todo_list
  end

  # Set the Todo by its id within the todo list
  def set_todo
    @todo = policy_scope(Todo).find_by(id: params[:id])
    unless @todo
    return render json: { error: 'Todo not found' }, status: :not_found 
    end
  end

  # Permit the necessary parameters for Todo creation and updating
  def todo_params
    params.require(:todo).permit(:title, :status)
  end
end
