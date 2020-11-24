class Account < ApplicationRecord
    belongs_to :owner, polymorphic: true, inverse_of: :account
    has_many :payments
end
