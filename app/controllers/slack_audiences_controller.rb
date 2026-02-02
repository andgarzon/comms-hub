class SlackAudiencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_audience, only: %i[edit update destroy]

  def index
    @audiences = SlackAudience.order(:name)
  end

  def new
    @audience = SlackAudience.new
  end

  def create
    @audience = SlackAudience.new(audience_params)
    if @audience.save
      redirect_to slack_audiences_path, notice: "Slack audience created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @audience.update(audience_params)
      redirect_to slack_audiences_path, notice: "Slack audience updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @audience.destroy
    redirect_to slack_audiences_path, notice: "Slack audience deleted."
  end

  private

  def set_audience
    @audience = SlackAudience.find(params[:id])
  end

  def audience_params
    params.require(:slack_audience).permit(:name, :slack_channel)
  end
end
