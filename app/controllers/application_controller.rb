class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_redirect_url, if: :devise_controller?

  def after_sign_in_path_for(_resource)
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

    return redirect_to_param if matches_this_domain redirect_to_param

    Rails.logger.error "Redirect failed. #{redirect_to_param} is not in the host domain #{this_domain}"
    nil
  end

  def matches_this_domain(url)
    redirect_url = URI.parse url
    redirect_url.host.ends_with? this_domain
  rescue StandardError => e
    Rails.logger.error e
  end

  def this_domain
    Rails.application.config.host
         .split('.')
         .last(2)
         .join('.')
  end

  def redirect_to_param
    params[:redirect_to]
  end
end
