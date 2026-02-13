module Authorizable
  extend ActiveSupport::Concern

  class NotAuthorizedError < StandardError; end

  included do
    rescue_from Authorizable::NotAuthorizedError, with: :handle_unauthorized
  end

  private

  def authorize_admin!
    raise NotAuthorizedError unless current_user.admin?
  end

  def authorize_audience_access!(audience)
    return if current_user.admin?
    return if audience.scope_type == "system"
    return if audience.scope_type == "role" && audience.scope_value == current_user.role
    return if audience.scope_type == "personal" && audience.created_by_id == current_user.id
    raise NotAuthorizedError
  end

  def authorize_audience_modify!(audience)
    return if current_user.admin?
    return if audience.owned_by?(current_user)
    raise NotAuthorizedError
  end

  def authorize_audience_create!(scope_type, scope_value)
    return if current_user.admin?

    case scope_type
    when "personal"
      # Any user can create personal audiences
      return
    when "role"
      # Users can only create audiences for their own role
      raise NotAuthorizedError unless scope_value == current_user.role
    when "system"
      # Only admins can create system audiences
      raise NotAuthorizedError
    else
      raise NotAuthorizedError
    end
  end

  def handle_unauthorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back fallback_location: root_path
  end
end
