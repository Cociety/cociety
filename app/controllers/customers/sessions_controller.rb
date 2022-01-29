# frozen_string_literal: true

class Customers::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  # Same as the default but allows other hosts on redirect
  # Default: https://github.com/heartcombo/devise/blob/025b1c873491908b346e4d394f54481ec18fb02c/app/controllers/devise/sessions_controller.rb#L75
  # Fix for error:
  # Customer::SessionControllerTest#test_redirects_to_given_url_after_login:
  # ActionController::Redirecting::UnsafeRedirectError: Unsafe redirect to "http://test.example.com", pass allow_other_host: true to redirect anyway.
  # test/controllers/customer/session_controller_test.rb:6:in `block in <class:SessionControllerTest>'
  # "other host" allow list is maintained in app/controllers/application_controller.rb
  def respond_to_on_destroy
    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name), allow_other_host: true }
    end
  end
end
