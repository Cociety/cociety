# Represents a Charge object from Stripe
# Multiple entries can exist for each charge tied to different events and states
class Charge < ApplicationRecord
  default_scope -> { order(stripe_created: :desc) }
  alias_attribute :source, :external_entity_source
  alias_attribute :event, :external_event
  belongs_to :external_entity_source
  belongs_to :customer
  enum status: { pending: 0, succeeded: 1, failed: 2 }
  has_one :external_event, foreign_key: %i[external_entity_source_id external_event_id]
  monetize :amount_cents
  scope :latest_for_stripe_id, ->(stripe_id) { where(stripe_id: stripe_id).order(stripe_created: :desc).limit(1).first }
  scope :with_payment_allocations, -> { includes(payment_allocations_association) }
  self.primary_keys = :external_entity_source_id, :external_event_id, :stripe_id

  # rubocop:disable Metrics/MethodLength
  def self.latest_succeeded_non_refunded(range = 0..2_147_483_647)
    query = <<-SQL
      SELECT
        *
      FROM (
        SELECT DISTINCT ON(stripe_id)
          *
        FROM
          charges
        WHERE
          stripe_created BETWEEN $1 and $2
        ORDER BY
          stripe_id,
          stripe_created DESC
      ) AS latest_events_per_charge
      WHERE
      refunded = false
      and "status" = $3
    SQL
    find_by_sql(query, [
                  [nil, range.begin],
                  [nil, range.end],
                  [nil, Charge.statuses[:succeeded]]
                ])
  end
  # rubocop:enable Metrics/MethodLength

  def self.payment_allocations_association
    {
      customer: {
        payment_allocation_sets: {
          payment_allocations: :organization
        }
      }
    }
  end

  def latest_for_self
    Charge.latest_for_stripe_id(stripe_id)
  end
end
