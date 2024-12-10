class UsersController < ApplicationController
  # GET 
  def index
    users = User.all
    render json: users
  end

  # GET
  def show
    user = User.find_by(id: params[:id])
    if user
      render json: user
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  # POST
  def create
    Rails.logger.debug "Received parameters: #{params.inspect}"
    user = User.new(user_params)
    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT/PATCH
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

  # DELETE
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

  def user_params
    params.permit(:name,:email, :password, :password_confirmation)  
  end
end