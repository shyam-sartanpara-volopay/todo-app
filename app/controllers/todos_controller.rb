class TodosController < ApplicationController

  before_action :authenticate_user!   # Ensure the user is authenticated via token
  before_action :set_todo_list
  before_action :set_todo, only: [:toggle_status, :update, :destroy, :create]

  # GET /users/:user_id/todo_lists/:todo_list_id/todos
  def index
    @todo = policy_scope(Todo)
    if @todo.none?
      render json: { error: 'Not Found' }, status: :not_found
    else
      render json: @todo
    end  
  
  end

  # POST /users/:user_id/todo_lists/:todo_list_id/todos
  def create
    @todo = @todo_list.todos.build(todo_params)
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
    authorize @todo
    if @todo.update(todo_params)
      render json: @todo
    else
      render json: { error: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /users/:user_id/todo_lists/:todo_list_id/todos/:id
  def destroy
    authorize @todo
    @todo.destroy
    head :no_content
  end

  private

  # Set the TodoList by user_id and todo_list_id
  def set_todo_list
    # Fetch the TodoList owned by the user or where the user is a collaborator
    @todo_list = TodoList.joins("LEFT JOIN collaborators ON collaborators.todo_list_id = todo_lists.id")
                         .where("todo_lists.user_id = :user_id OR collaborators.user_id = :user_id", user_id: current_user.id)
                         .find_by(id: params[:todo_list_id])
  
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
