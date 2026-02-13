class SlackAudiencesController < ApplicationController
  before_action :set_audience, only: %i[ edit update destroy ]
  before_action :authorize_edit!, only: %i[ edit update destroy ]

  def index
    @audiences = SlackAudience.merge(Audience.visible_to(current_user)).order(:name)
  end

  def new
    @audience = SlackAudience.new
  end

  def create
    @audience = SlackAudience.new(audience_params)
    @audience.creator = current_user
    @audience.scope_type ||= "personal"

    authorize_audience_create!(@audience.scope_type, @audience.scope_value)

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
    redirect_to slack_audiences_path, notice: "Slack audience deleted.", status: :see_other
  end

  private

  def set_audience
    @audience = SlackAudience.find(params[:id])
  end

  def authorize_edit!
    authorize_audience_modify!(@audience)
  end

  def audience_params
    params.require(:slack_audience).permit(:name, :slack_channel, :scope_type, :scope_value)
  end
end
