# Represents a Charge object from Stripe
# Multiple entries can exist for each charge tied to different events and states
class Charge < ApplicationRecord
  default_scope -> { order(stripe_created: :desc) }
  alias_attribute :source, :external_entity_source
  alias_attribute :event, :external_event
  belongs_to :external_entity_source
  enum status: { pending: 0, succeeded: 1, failed: 2 }
  has_one :external_event, foreign_key: %i[external_entity_source_id external_event_id]
  monetize :amount_cents
  scope :testt, -> { find_by_sql('SELECT * FROM charges') }
  self.primary_keys = :external_entity_source_id, :external_event_id, :stripe_id

  def self.latest(range=0..2147483647)
    query = <<-SQL
      SELECT DISTINCT ON(stripe_id)
        amount_cents,
        amount_currency,
        refunded,
        'status',
        stripe_created,
        stripe_id,
        external_event_id,
        external_entity_source_id,
        created_at,
        updated_at
      FROM
        charges
      WHERE
        stripe_created BETWEEN $1 and $2
      ORDER BY
        stripe_id,
        stripe_created DESC
    SQL
    find_by_sql(query, [
                  [nil, range.begin],
                  [nil, range.end]
                ])
  end

  def latest_for_self
    Charge.where(stripe_id: stripe_id).order(stripe_created: :desc).limit(1).first
  end
end
