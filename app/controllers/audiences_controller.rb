class AudiencesController < ApplicationController
  before_action :set_audience, only: %i[ show edit update destroy ]
  before_action :authorize_view!, only: %i[ show ]
  before_action :authorize_edit!, only: %i[ edit update destroy ]

  def index
    @audiences = Audience.visible_to(current_user).order(:name)
  end

  def show
  end

  def new
    @audience = Audience.new
    @available_scope_types = available_scope_types
    @available_roles = available_roles_for_scope
  end

  def edit
    @available_scope_types = available_scope_types
    @available_roles = available_roles_for_scope
  end

  def create
    safe_params = audience_params
    # Convert blank type to nil so a plain Audience is created (not an invalid STI subclass)
    audience_type = safe_params[:type].presence
    klass = if audience_type.present? && %w[SlackAudience EmailAudience WhatsappAudience].include?(audience_type)
              audience_type.constantize
            else
              Audience
            end

    @audience = klass.new(safe_params.except(:type))
    @audience.creator = current_user

    # Enforce scope authorization
    authorize_audience_create!(@audience.scope_type || "personal", @audience.scope_value)

    # Non-admins creating role audiences are forced to their own role
    if @audience.scope_type == "role" && !current_user.admin?
      @audience.scope_value = current_user.role
    end

    respond_to do |format|
      if @audience.save
        format.html { redirect_to @audience, notice: "Audience was successfully created." }
        format.json { render :show, status: :created, location: @audience }
      else
        @available_scope_types = available_scope_types
        @available_roles = available_roles_for_scope
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @audience.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @audience.update(audience_params)
        format.html { redirect_to @audience, notice: "Audience was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @audience }
      else
        @available_scope_types = available_scope_types
        @available_roles = available_roles_for_scope
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @audience.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @audience.destroy!

    respond_to do |format|
      format.html { redirect_to audiences_path, notice: "Audience was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_audience
    @audience = Audience.find(params.expect(:id))
  end

  def authorize_view!
    authorize_audience_access!(@audience)
  end

  def authorize_edit!
    authorize_audience_modify!(@audience)
  end

  def audience_params
    params.expect(audience: [ :name, :description, :slack_channel, :type, :scope_type, :scope_value, :email_recipients, :whatsapp_recipients ])
  end

  def available_scope_types
    if current_user.admin?
      Audience::SCOPE_TYPES
    else
      %w[personal role]
    end
  end

  def available_roles_for_scope
    if current_user.admin?
      User::ROLES.reject { |r| r == "admin" }
    else
      [ current_user.role ].compact
    end
  end
end
