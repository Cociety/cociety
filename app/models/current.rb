class Current < ActiveSupport::CurrentAttributes
  attribute :customer

  def customer=(customer)
    super
  end
end
