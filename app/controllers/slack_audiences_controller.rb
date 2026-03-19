class SlackAudiencesController < ApplicationController
  before_action :set_audience, only: %i[ edit update destroy ]
  before_action :authorize_edit!, only: %i[ edit update destroy ]

  def index
    @audiences = SlackAudience.merge(Audience.visible_to(current_user)).order(:name)
  end

  def new
    @audience = SlackAudience.new
    load_contacts_for_form
  end

  def create
    @audience = SlackAudience.new(audience_params)
    @audience.creator = current_user
    @audience.scope_type ||= "personal"

    authorize_audience_create!(@audience.scope_type, @audience.scope_value)

    if @audience.save
      update_audience_contacts(@audience)
      redirect_to slack_audiences_path, notice: "Slack audience created."
    else
      load_contacts_for_form
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_contacts_for_form
  end

  def update
    if @audience.update(audience_params)
      update_audience_contacts(@audience)
      redirect_to slack_audiences_path, notice: "Slack audience updated."
    else
      load_contacts_for_form
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

  def load_contacts_for_form
    @contacts = Contact.active.where.not(slack_username: [nil, ""]).order(:name)
    @contact_lists = ContactList.order(:name)
  end

  def update_audience_contacts(audience)
    contact_ids = []

    if params[:contact_ids].present?
      contact_ids += Array(params[:contact_ids]).map(&:to_i)
    end

    if params[:contact_list_ids].present?
      list_ids = Array(params[:contact_list_ids]).map(&:to_i)
      list_contact_ids = Contact.active.where(contact_list_id: list_ids).pluck(:id)
      contact_ids += list_contact_ids
    end

    audience.contact_ids = contact_ids.uniq
  end
end
