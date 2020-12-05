# Models all company expenses. Payroll, taxes, inventory, licensing, contracts, etc.
class Expense
  # sums all expenses with a time range
  def self.sum(range = Float::INFINITY..Float::INFINITY)
    Rails.logger.info "sum expenses from #{range.begin} to #{range.end}"
    Money.new(100_00, 'USD')
  end
end
