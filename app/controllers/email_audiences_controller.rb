class EmailAudiencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_audience, only: %i[edit update destroy]

  def index
    @audiences = EmailAudience.order(:name)
  end

  def new
    @audience = EmailAudience.new
  end

  def create
    @audience = EmailAudience.new(audience_params)
    if @audience.save
      redirect_to email_audiences_path, notice: "Email audience created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @audience.update(audience_params)
      redirect_to email_audiences_path, notice: "Email audience updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @audience.destroy
    redirect_to email_audiences_path, notice: "Email audience deleted."
  end

  private

  def set_audience
    @audience = EmailAudience.find(params[:id])
  end

  def audience_params
    params.require(:email_audience).permit(:name, :email_recipients)
  end
end

