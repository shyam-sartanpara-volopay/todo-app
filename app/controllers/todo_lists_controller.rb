class TodoListsController < ApplicationController
    # GET /users/:user_id/todo_lists
    def index
        @user = User.find_by(id: params[:user_id]) # Fetch user by ID
        if @user
          @todo_lists = @user.todo_lists
          render json: @todo_lists
        else
          render json: { error: "User not found" }, status: :not_found
        end
      end
      
  
    # POST /todo_lists
    def create
      user = User.find_by(id: todo_list_params[:user_id])
      if user
        todo_list = user.todo_lists.new(title: todo_list_params[:title])
        if todo_list.save
          render json: todo_list, status: :created
        else
          render json: { errors: todo_list.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: "User not found" }, status: :not_found
      end
    end
  
    # PUT/PATCH /todo_lists/:id
    def update
      todo_list = TodoList.find_by(id: params[:id])
      if todo_list
        if todo_list.update(todo_list_params.except(:user_id)) # Exclude `user_id` on updates
          render json: todo_list
        else
          render json: { errors: todo_list.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: "TodoList not found" }, status: :not_found
      end
    end
  
    # DELETE /todo_lists/:id
    def destroy
      todo_list = TodoList.find_by(id: params[:id])
      if todo_list
        todo_list.destroy
        render json: { message: "TodoList deleted successfully" }, status: :ok
      else
        render json: { error: "TodoList not found" }, status: :not_found
      end
    end
  
    private
  
    # Strong parameters
    def todo_list_params
      params.require(:todo_list).permit(:title, :user_id)
    end
  end
  