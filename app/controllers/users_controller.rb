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

  def bulk_new
  end

  def bulk_create
    unless params[:csv_file].present?
      flash.now[:alert] = "Please upload a CSV file."
      return render :bulk_new, status: :unprocessable_entity
    end

    role = params[:role]
    unless User::ROLES.include?(role)
      flash.now[:alert] = "Please select a valid role."
      return render :bulk_new, status: :unprocessable_entity
    end

    file = params[:csv_file]
    emails = parse_csv_emails(file)

    if emails.empty?
      flash.now[:alert] = "No valid emails found in the CSV. Ensure the file has an 'email' column header."
      return render :bulk_new, status: :unprocessable_entity
    end

    created = []
    skipped = []
    errors = []

    emails.each do |email|
      email = email.strip.downcase
      if User.exists?(email: email)
        skipped << email
        next
      end

      password = SecureRandom.hex(8)
      user = User.new(email: email, password: password, password_confirmation: password, role: role)
      if user.save
        created << email
      else
        errors << "#{email}: #{user.errors.full_messages.join(', ')}"
      end
    end

    messages = []
    messages << "#{created.size} user(s) created." if created.any?
    messages << "#{skipped.size} skipped (already exist)." if skipped.any?
    messages << "#{errors.size} failed: #{errors.join('; ')}" if errors.any?

    if errors.any?
      redirect_to bulk_new_manage_users_path, alert: messages.join(" ")
    else
      redirect_to manage_users_path, notice: messages.join(" ")
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

  def parse_csv_emails(file)
    require "csv"
    content = file.read
    csv = CSV.parse(content, headers: true, header_converters: :downcase)

    if csv.headers.include?("email")
      csv.map { |row| row["email"] }.compact.reject(&:blank?)
    else
      # Fallback: try first column if no header match
      csv.map { |row| row[0] }.compact.reject(&:blank?).select { |v| v.include?("@") }
    end
  rescue CSV::MalformedCSVError
    []
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end
end
