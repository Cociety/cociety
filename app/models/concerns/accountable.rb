module Accountable
  extend ActiveSupport::Concern

  included do
    after_create :create_account
    has_one :account, as: :owner, inverse_of: :owner
    has_many :payments, through: :account
  end

  private

  def create_account
    self.build_account.save!
  end
end