class HomeController < ApplicationController
  ANNOUNCEMENTS_PER_PAGE = 4

  def index
    @total_announcements = Announcement.count
    @draft_announcements = Announcement.drafts.count
    @scheduled_announcements = Announcement.scheduled_items.count
    @sent_announcements = Announcement.sent_items.count

    @total_contacts = Contact.count
    @active_contacts = Contact.active.count

    @total_audiences = Audience.count
    @total_contact_lists = ContactList.count

    @announcements_page = (params[:ann_page].presence || 1).to_i
    @announcements_total_pages = (Announcement.count / ANNOUNCEMENTS_PER_PAGE.to_f).ceil
    @announcements_total_pages = 1 if @announcements_total_pages < 1
    @announcements_page = @announcements_page.clamp(1, @announcements_total_pages)
    @recent_announcements = Announcement.order(created_at: :desc)
                                        .offset((@announcements_page - 1) * ANNOUNCEMENTS_PER_PAGE)
                                        .limit(ANNOUNCEMENTS_PER_PAGE)

    @recent_contacts = Contact.order(created_at: :desc).limit(4)
    @recent_audiences = Audience.order(created_at: :desc).limit(4)
  end
end
