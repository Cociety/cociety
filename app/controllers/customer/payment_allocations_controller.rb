class Customer::PaymentAllocationsController < ApplicationController
  def create
    @payment_allocation_set = PaymentAllocationSet.new(
      customer:            current_customer,
      payment_allocations: payment_allocations_params.map { |p| PaymentAllocation.new(p) }
    )
    if @payment_allocation_set.save
      flash[:notice] = t(:payment_allocations_updated)
    else
      flash[:alert] = @payment_allocation_set.errors.full_messages
    end
    redirect_back fallback_location: customer_profile_index_path
  end

  private

  def payment_allocations_params
    params.permit(payment_allocations: %i[percent organization_id]).require(:payment_allocations)
  end
end
