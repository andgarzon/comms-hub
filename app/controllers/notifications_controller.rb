class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order(created_at: :desc).limit(30)
  end

  def mark_read
    current_user.notifications.unread.update_all(read: true)
    redirect_back fallback_location: notifications_path
  end

  def mark_one_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_read!
    redirect_to announcement_path(notification.announcement)
  end
end
