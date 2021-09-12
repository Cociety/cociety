class Customer::AvatarController < ApplicationController
  before_action :set_customer

  def index
    if @customer.avatar.attached?
      avatar = @customer.avatar.variant(resize_to_fill: [100, 100]).processed
      redirect_to url_for(avatar)
    else
      render inline: render_to_string(partial: 'customer/initials.svg', locals: { initials: @customer.name.initials }), content_type: 'image/svg+xml', disposition: :inline
    end
  end

  def set_customer
    @customer = Customer.find_by(id: params[:customer_id])
    head :not_found unless @customer
  end
end