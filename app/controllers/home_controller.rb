class HomeController < ApplicationController
  def index
    @total_announcements = Announcement.count
    @draft_announcements = Announcement.drafts.count
    @scheduled_announcements = Announcement.scheduled_items.count
    @sent_announcements = Announcement.sent_items.count

    @total_contacts = Contact.count
    @active_contacts = Contact.active.count

    @total_audiences = Audience.count
    @total_contact_lists = ContactList.count

    @recent_announcements = Announcement.order(created_at: :desc).limit(4)
    @recent_contacts = Contact.order(created_at: :desc).limit(4)
    @recent_audiences = Audience.order(created_at: :desc).limit(4)
  end
end
