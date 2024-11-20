class UsersController < ApplicationController
  # GET /users
  def index
    users = User.all
    render json: users
  end

  # GET /users/:id
  def show
    user = User.find_by(id: params[:id])
    if user
      render json: user
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  # POST /users
  def create
    user = User.new(user_params)
    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT/PATCH /users/:id
  def update
    user = User.find_by(id: params[:id])
    if user
      if user.update(user_params)
        render json: user
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  # DELETE /users/:id
  def destroy
    user = User.find_by(id: params[:id])
    if user
      user.destroy
      render json: { message: "User deleted successfully" }, status: :ok
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  private

  # Strong parameters
  def user_params
    params.require(:user).permit(:name, :email)
  end
end