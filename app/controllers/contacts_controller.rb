class ContactsController < ApplicationController
  before_action :authorize_admin!
  before_action :set_contact, only: %i[show edit update destroy toggle_active]

  def index
    @contacts = Contact.includes(:contact_list).order(:name)
    @contacts = @contacts.search(params[:search]) if params[:search].present?
    @contacts = @contacts.by_company(params[:company]) if params[:company].present?
    @contacts = @contacts.by_type(params[:contact_type]) if params[:contact_type].present?
    @contacts = @contacts.by_list(params[:contact_list_id]) if params[:contact_list_id].present?
    @contacts = @contacts.where(active: params[:active] == "true") if params[:active].present?

    @companies = Contact.where.not(company: [nil, ""]).distinct.pluck(:company).sort
    @contact_lists = ContactList.order(:name)
  end

  def show
  end

  def new
    @contact = Contact.new
    @contact.contact_list_id = params[:contact_list_id] if params[:contact_list_id]
    @contact_lists = ContactList.order(:name)
  end

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      redirect_to @contact, notice: "Contact created successfully."
    else
      @contact_lists = ContactList.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @contact_lists = ContactList.order(:name)
  end

  def update
    if @contact.update(contact_params)
      redirect_to @contact, notice: "Contact updated successfully."
    else
      @contact_lists = ContactList.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.destroy!
    redirect_to contacts_path, notice: "Contact deleted.", status: :see_other
  end

  def toggle_active
    @contact.update!(active: !@contact.active?)
    redirect_back fallback_location: contacts_path, notice: "Contact #{@contact.active? ? 'activated' : 'deactivated'}."
  end

  def import
    @contact_lists = ContactList.order(:name)
  end

  def process_import
    unless params[:csv_file].present?
      flash.now[:alert] = "Please upload a CSV file."
      @contact_lists = ContactList.order(:name)
      return render :import, status: :unprocessable_entity
    end

    contact_list_id = params[:contact_list_id].presence
    if contact_list_id.present?
      contact_list = ContactList.find(contact_list_id)
    end

    file = params[:csv_file]
    result = import_contacts_from_csv(file, contact_list)

    messages = []
    messages << "#{result[:created]} contact(s) imported." if result[:created] > 0
    messages << "#{result[:updated]} contact(s) updated." if result[:updated] > 0
    messages << "#{result[:skipped]} duplicate(s) skipped." if result[:skipped] > 0
    messages << "#{result[:errors].size} error(s)." if result[:errors].any?

    if result[:errors].any?
      redirect_to import_contacts_path, alert: messages.join(" ")
    else
      redirect_to contacts_path, notice: messages.join(" ")
    end
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(
      :name, :email, :phone_number, :slack_username,
      :company, :department, :contact_type, :active, :contact_list_id
    )
  end

  def import_contacts_from_csv(file, contact_list)
    require "csv"
    content = file.read.force_encoding("UTF-8")
    csv = CSV.parse(content, headers: true, header_converters: :downcase)

    result = { created: 0, updated: 0, skipped: 0, errors: [] }
    duplicate_handling = params[:duplicate_handling] || "skip"

    csv.each_with_index do |row, index|
      name = row["name"]&.strip
      email = row["email"]&.strip&.downcase
      next if name.blank? && email.blank?

      attrs = {
        name: name.presence || email,
        email: email,
        phone_number: row["phone_number"]&.strip || row["phone"]&.strip,
        slack_username: row["slack_username"]&.strip || row["slack"]&.strip,
        company: row["company"]&.strip,
        department: row["department"]&.strip,
        contact_type: row["contact_type"]&.strip&.downcase || row["type"]&.strip&.downcase || "employee",
        contact_list: contact_list,
        active: true
      }

      # Validate contact_type
      unless Contact::CONTACT_TYPES.include?(attrs[:contact_type])
        attrs[:contact_type] = "employee"
      end

      existing = email.present? ? Contact.find_by(email: email, company: attrs[:company]) : nil

      if existing
        if duplicate_handling == "update"
          existing.update!(attrs.except(:active))
          result[:updated] += 1
        else
          result[:skipped] += 1
        end
      else
        Contact.create!(attrs)
        result[:created] += 1
      end
    rescue => e
      result[:errors] << "Row #{index + 2}: #{e.message}"
    end

    result
  rescue CSV::MalformedCSVError => e
    { created: 0, updated: 0, skipped: 0, errors: ["Invalid CSV file: #{e.message}"] }
  end
end
