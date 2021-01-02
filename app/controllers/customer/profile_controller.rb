class Customer::ProfileController < ApplicationController
  before_action :set_pending_reconfirmation_before_action, only: [:update]

  def update
    if current_customer.update(customer_params)
      flash[:notice] = update_notice_message
    else
      flash[:alert] = current_customer.errors.full_messages
    end
    redirect_back fallback_location: customer_profile_index_path
  end

  private

  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :email, :avatar)
  end

  def set_pending_reconfirmation_before_action
    @pending_reconfirmation_before_action = current_customer.pending_reconfirmation?
  end

  def update_notice_message
    if !@pending_reconfirmation_before_action && current_customer.pending_reconfirmation?
      t '.email_success'
    else
      t '.success'
    end
  end
end
