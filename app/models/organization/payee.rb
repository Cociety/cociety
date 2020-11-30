module Organization::Payee
  extend ActiveSupport::Concern

  def pay(cents, currency)
    message = "Paying #{name} #{cents} cents in #{currency}"
    Rails.logger.info message
    message
  end
end
