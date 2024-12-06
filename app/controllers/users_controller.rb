class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :authenticate_user!

  # GET /users
  def index
    @users = User.all
    render json: @users
  end

  # POST /users
  def create
    @user = User.new(user_params)
    
    if @user.save
      render json: @user, status: :created
    else
      render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /users/:id
  def show
    render json: @user, include: :todo_lists
  end

  # PUT /users/:id
  def update
    # If the password is not provided in the update, we want to skip validation for it
    if user_params[:password].blank?
      user_params.delete(:password) # This prevents the empty password from causing a validation error
    end

    if @user.update(user_params)
      render json: @user
    else
      render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    return render json: { error: 'User not found' }, status: :not_found unless @user
  end

  # Modify user_params to permit :password, :email, and :name
  def user_params
    params.require(:user).permit(:email, :password, :name)
  end
end
