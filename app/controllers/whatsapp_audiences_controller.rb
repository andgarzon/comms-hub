class WhatsappAudiencesController < ApplicationController
  before_action :set_audience, only: %i[ edit update destroy ]
  before_action :authorize_edit!, only: %i[ edit update destroy ]

  def index
    @audiences = WhatsappAudience.merge(Audience.visible_to(current_user)).order(:name)
  end

  def new
    @audience = WhatsappAudience.new
  end

  def create
    @audience = WhatsappAudience.new(audience_params)
    @audience.creator = current_user
    @audience.scope_type ||= "personal"

    authorize_audience_create!(@audience.scope_type, @audience.scope_value)

    if @audience.save
      redirect_to whatsapp_audiences_path, notice: "WhatsApp audience created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @audience.update(audience_params)
      redirect_to whatsapp_audiences_path, notice: "WhatsApp audience updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @audience.destroy
    redirect_to whatsapp_audiences_path, notice: "WhatsApp audience deleted.", status: :see_other
  end

  private

  def set_audience
    @audience = WhatsappAudience.find(params[:id])
  end

  def authorize_edit!
    authorize_audience_modify!(@audience)
  end

  def audience_params
    params.require(:whatsapp_audience).permit(:name, :whatsapp_recipients, :scope_type, :scope_value)
  end
end
