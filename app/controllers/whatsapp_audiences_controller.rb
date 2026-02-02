class WhatsappAudiencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_audience, only: %i[edit update destroy]

  def index
    @audiences = WhatsappAudience.order(:name)
  end

  def new
    @audience = WhatsappAudience.new
  end

  def create
    @audience = WhatsappAudience.new(audience_params)
    if @audience.save
      redirect_to whatsapp_audiences_path, notice: "Whatsapp audience created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @audience.update(audience_params)
      redirect_to whatsapp_audiences_path, notice: "Whatsapp audience updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @audience.destroy
    redirect_to whatsapp_audiences_path, notice: "Whatsapp audience deleted."
  end

  private

  def set_audience
    @audience = WhatsappAudience.find(params[:id])
  end

  def audience_params
    params.require(:whatsapp_audience).permit(:name, :whatsapp_recipients)
  end
end

