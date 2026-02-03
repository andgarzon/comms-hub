# app/controllers/announcements_controller.rb
class AnnouncementsController < ApplicationController
  before_action :set_audiences, only: %i[new create]
  before_action :set_announcement, only: %i[show schedule cancel_schedule send_now]

  def index
    @announcements = Announcement.order(created_at: :desc).includes(:user)
  end

  def show
  end

  def new
    @announcement = Announcement.new
    @slack_audiences = SlackAudience.order(:name)
    @email_audiences = EmailAudience.order(:name)
    @whatsapp_audiences = WhatsappAudience.order(:name)
  end

  def create
    @slack_audiences = SlackAudience.order(:name)
    @email_audiences = EmailAudience.order(:name)
    @whatsapp_audiences = WhatsappAudience.order(:name)
    
    @announcement = current_user.announcements.build(announcement_params)

    # 1) "Improve with AI" flow - REDIRECT to avoid turbo issues
    if params[:improve_with_ai]
      if @announcement.save(validate: false)
        AnnouncementAiRewriter.new(@announcement).call
        redirect_to new_announcement_path(improved_id: @announcement.id), notice: "AI improvements applied! Review and submit when ready."
      else
        flash.now[:alert] = "Please fix errors before improving with AI."
        render :new, status: :unprocessable_entity
      end
      return
    end

    # 2) Normal create flow (save + enqueue)
    if @announcement.save
      enqueue_or_schedule(@announcement)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def schedule
    scheduled_for = params.dig(:announcement, :scheduled_for)

    if scheduled_for.blank?
      @announcement.update!(scheduled_for: nil, status: "queued")
      SendAnnouncementJob.perform_later(@announcement.id)
      redirect_to @announcement, notice: "Queued to send now."
      return
    end

    @announcement.update!(scheduled_for: scheduled_for, status: "scheduled")
    SendAnnouncementJob.set(wait_until: @announcement.scheduled_for).perform_later(@announcement.id)

    redirect_to @announcement, notice: "Rescheduled."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to @announcement, alert: e.record.errors.full_messages.to_sentence
  end

  def cancel_schedule
    @announcement.update!(status: "draft", scheduled_for: nil)
    redirect_to @announcement, notice: "Schedule canceled."
  end

  def send_now
    @announcement.update!(status: "queued", scheduled_for: nil)
    SendAnnouncementJob.perform_later(@announcement.id)
    redirect_to @announcement, notice: "Retry queued."
  end

  private

  def enqueue_or_schedule(announcement)
    if announcement.scheduled_for.present?
      announcement.update!(status: "scheduled")
      SendAnnouncementJob.set(wait_until: announcement.scheduled_for).perform_later(announcement.id)
      redirect_to announcement, notice: "Announcement scheduled."
    else
      announcement.update!(status: "queued")
      SendAnnouncementJob.perform_later(announcement.id)
      redirect_to announcement, notice: "Announcement queued."
    end
  end

  def set_audiences
    @slack_audiences = SlackAudience.order(:name)
    @email_audiences = EmailAudience.order(:name)
    @whatsapp_audiences = WhatsappAudience.order(:name)
  end

  def set_announcement
    @announcement = current_user.announcements.find(params[:id])
  end

  def announcement_params
    params.require(:announcement).permit(
      :title,
      :base_body,
      :email_body,
      :slack_body,
      :whatsapp_body,
      :send_to_slack,
      :send_to_email,
      :send_to_whatsapp,
      :scheduled_for,
      audience_ids: []
    )
  end
end
