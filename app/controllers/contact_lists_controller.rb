class ContactListsController < ApplicationController
  before_action :authorize_admin!
  before_action :set_contact_list, only: %i[show edit update destroy]

  def index
    @contact_lists = ContactList.all.order(:name)
  end

  def show
    @contacts = @contact_list.contacts.order(:name)
    @contacts = @contacts.search(params[:search]) if params[:search].present?
  end

  def new
    @contact_list = ContactList.new
  end

  def create
    @contact_list = ContactList.new(contact_list_params)

    if @contact_list.save
      redirect_to @contact_list, notice: "Contact list created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @contact_list.update(contact_list_params)
      redirect_to @contact_list, notice: "Contact list updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact_list.destroy!
    redirect_to contact_lists_path, notice: "Contact list deleted.", status: :see_other
  end

  private

  def set_contact_list
    @contact_list = ContactList.find(params[:id])
  end

  def contact_list_params
    params.require(:contact_list).permit(:name, :description, :company, :list_type)
  end
end
