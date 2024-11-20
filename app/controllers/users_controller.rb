class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

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

  def user_params
    params.require(:user).permit(:name)
  end
end
