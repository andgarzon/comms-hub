class UsersController < ApplicationController
  before_action :authorize_admin!, except: [ :show ]
  before_action :set_user, only: %i[ show edit update destroy ]

  def index
    @users = User.order(:email)
    @users = @users.where("email LIKE ?", "%#{params[:search]}%") if params[:search].present?
    @users = @users.where(role: params[:role]) if params[:role].present?
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to manage_users_path, notice: "User created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    update_attrs = user_params
    update_attrs = update_attrs.except(:password, :password_confirmation) if update_attrs[:password].blank?

    if @user.update(update_attrs)
      redirect_to manage_user_path(@user), notice: "User updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to manage_users_path, alert: "You cannot delete yourself."
      return
    end
    @user.destroy
    redirect_to manage_users_path, notice: "User deleted.", status: :see_other
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end
end
