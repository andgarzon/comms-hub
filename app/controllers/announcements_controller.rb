# app/controllers/announcements_controller.rb
class AnnouncementsController < ApplicationController
  before_action :set_audiences, only: %i[new create edit update]
  before_action :set_announcement, only: %i[show edit update schedule cancel_schedule send_now duplicate]

  PER_PAGE = 9

  def index
    @current_status = params[:status].presence
    @search = params[:search].presence
    @announcements = Announcement.order(created_at: :desc).includes(:user)
    @announcements = @announcements.by_status(@current_status) if @current_status.present?
    @announcements = @announcements.where("title ILIKE ?", "%#{sanitize_sql_like(@search)}%") if @search

    # Counts for filter tabs
    @status_counts = {
      all: Announcement.count,
      draft: Announcement.drafts.count,
      scheduled: Announcement.scheduled_items.count,
      sent: Announcement.sent_items.count,
      failed: Announcement.failed_items.count
    }

    # Pagination
    @total_count = @announcements.count
    @current_page = (params[:page].presence || 1).to_i
    @total_pages = (@total_count.to_f / PER_PAGE).ceil
    @current_page = [[@current_page, 1].max, [@total_pages, 1].max].min
    @announcements = @announcements.offset((@current_page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def show
  end

  def edit
    unless @announcement.status.in?(%w[draft failed])
      redirect_to @announcement, alert: "Only draft or failed announcements can be edited."
    end
  end

  def update
    unless @announcement.status.in?(%w[draft failed])
      redirect_to @announcement, alert: "Only draft or failed announcements can be edited."
      return
    end

    @announcement.assign_attributes(announcement_params)

    # "Improve with AI" flow
    if params[:improve_with_ai]
      if @announcement.title.blank?
        @announcement.errors.add(:title, "can't be blank")
        flash.now[:alert] = "Please add a title before improving with AI."
        render :edit, status: :unprocessable_content
        return
      end

      if @announcement.base_body.blank?
        @announcement.errors.add(:base_body, "can't be blank")
        flash.now[:alert] = "Please add a base message before improving with AI."
        render :edit, status: :unprocessable_content
        return
      end

      if @announcement.save
        begin
          AnnouncementAiRewriter.new(@announcement).call
          redirect_to edit_announcement_path(@announcement), notice: "AI improvements applied! Review and submit when ready."
        rescue => e
          flash.now[:alert] = "AI improvement failed: #{e.message}. Please try again."
          render :edit, status: :unprocessable_content
        end
      else
        flash.now[:alert] = "Could not save announcement for AI improvement."
        render :edit, status: :unprocessable_content
      end
      return
    end

    # Save as Draft flow
    if params[:save_draft]
      @announcement.status = "draft"
      if @announcement.save
        redirect_to @announcement, notice: "Draft updated successfully."
      else
        render :edit, status: :unprocessable_content
      end
      return
    end

    # Send / Schedule flow
    if @announcement.save
      enqueue_or_schedule(@announcement)
    else
      render :edit, status: :unprocessable_content
    end
  end

  def new
    @announcement = Announcement.new
  end

  def create
    @announcement = current_user.announcements.build(announcement_params)

    # 1) "Improve with AI" flow - REDIRECT to avoid turbo issues
    if params[:improve_with_ai]
      # Validate only title and base_body for AI improvement
      if @announcement.title.blank?
        @announcement.errors.add(:title, "can't be blank")
        flash.now[:alert] = "Please add a title before improving with AI."
        render :new, status: :unprocessable_content
        return
      end
      
      if @announcement.base_body.blank?
        @announcement.errors.add(:base_body, "can't be blank")
        flash.now[:alert] = "Please add a base message before improving with AI."
        render :new, status: :unprocessable_content
        return
      end

      # Save without full validation, then improve
      if @announcement.save(validate: false)
        begin
          AnnouncementAiRewriter.new(@announcement).call
          redirect_to new_announcement_path(improved_id: @announcement.id), notice: "AI improvements applied! Review and submit when ready."
        rescue => e
          flash.now[:alert] = "AI improvement failed: #{e.message}. Please try again."
          render :new, status: :unprocessable_content
        end
      else
        flash.now[:alert] = "Could not save announcement for AI improvement."
        render :new, status: :unprocessable_content
      end
      return
    end

    # 2) Save as Draft flow
    if params[:save_draft]
      @announcement.status = "draft"
      if @announcement.save
        redirect_to @announcement, notice: "Announcement saved as draft."
      else
        render :new, status: :unprocessable_content
      end
      return
    end

    # 3) Normal create flow (save + enqueue)
    if @announcement.save
      enqueue_or_schedule(@announcement)
    else
      render :new, status: :unprocessable_content
    end
  end

  def schedule
    scheduled_for = params.dig(:announcement, :scheduled_for)

    if scheduled_for.blank?
      @announcement.update!(scheduled_for: nil, status: "draft")
      SendAnnouncementJob.perform_later(@announcement.id)
      redirect_to @announcement, notice: "Sending now."
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
    @announcement.update!(status: "draft", scheduled_for: nil)
    SendAnnouncementJob.perform_later(@announcement.id)
    redirect_to @announcement, notice: "Retry queued."
  end

  def duplicate
    new_announcement = @announcement.dup
    new_announcement.assign_attributes(
      status: "draft",
      scheduled_for: nil,
      title: "#{@announcement.title} (Copy)",
      user: current_user
    )
    if new_announcement.save
      # Copy audience associations
      @announcement.audience_ids.each do |audience_id|
        new_announcement.announcement_audiences.create(audience_id: audience_id)
      end
      redirect_to edit_announcement_path(new_announcement), notice: "Announcement duplicated as draft."
    else
      redirect_to @announcement, alert: "Could not duplicate announcement."
    end
  end

  private

  def enqueue_or_schedule(announcement)
    if announcement.scheduled_for.present?
      announcement.update!(status: "scheduled")
      SendAnnouncementJob.set(wait_until: announcement.scheduled_for).perform_later(announcement.id)
      redirect_to announcement, notice: "Announcement scheduled."
    else
      announcement.update!(status: "draft")
      SendAnnouncementJob.perform_later(announcement.id)
      redirect_to announcement, notice: "Announcement sending now."
    end
  end

  def set_audiences
    visible = Audience.visible_to(current_user)
    @slack_audiences = SlackAudience.merge(visible).order(:name)
    @email_audiences = EmailAudience.merge(visible).order(:name)
    @whatsapp_audiences = WhatsappAudience.merge(visible).order(:name)
  end

  def set_announcement
    @announcement = current_user.announcements.find(params[:id])
  end

  def sanitize_sql_like(string)
    string.gsub(/[%_\\]/) { |m| "\\#{m}" }
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
