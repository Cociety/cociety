class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_redirect_url, if: :devise_controller?

  def after_sign_in_path_for(_resource)
    redirect_url || root_path
  end

  def after_sign_out_path_for(_resource)
    redirect_url || root_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :email, :password) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :email, :password, :current_password) }
  end

  def set_redirect_url
    @redirect_url = redirect_url
  end

  def redirect_url
    return nil unless redirect_to_param

    return redirect_to_param if Domain.matches_second_level_of_current? redirect_to_param

    Rails.logger.error "Redirect failed. #{redirect_to_param} is not in the host domain #{Domain.current}"
    nil
  end

  def redirect_to_param
    params[:redirect_to]
  end
end
