require 'test_helper'

class CustomerTierTest < ActiveSupport::TestCase
  test 'has a customer' do
    assert customer_tiers(:one_first).customer
  end

  test 'refuses to save without a customer' do
    assert_raise ActiveRecord::RecordInvalid do
      assert CustomerTier.new(expiration: Time.now, tier: Tier.first).save!
    end
    assert CustomerTier.new(customer: customers(:two), expiration: Time.now, tier: Tier.first).save!
  end

  test 'refuses to save without an expiration date' do
    assert_raise ActiveRecord::NotNullViolation do
      CustomerTier.new(customer: customers(:two), tier: Tier.first).save!
    end
    assert CustomerTier.new(customer: customers(:two), expiration: Time.now, tier: Tier.first).save!
  end

  test 'refuses to save without a tier' do
    assert_raise ActiveRecord::RecordInvalid do
      CustomerTier.new(customer: customers(:two), expiration: Time.now).save!
    end
    assert CustomerTier.new(customer: customers(:two), expiration: Time.now, tier: Tier.first).save!
  end

  test 'automatically sets effective date to now' do
    now = Time.now
    ct = CustomerTier.new(customer: customers(:two), expiration: Time.now, tier: Tier.first)
    ct.save!
    assert_equal now.to_i, ct.effective.to_i
  end

  test 'refuses to save a customer tier that overlaps with an existing one' do
    assert CustomerTier.new(customer: customers(:four), effective: Time.now, expiration: 1.month.from_now, tier: Tier.first).save!
    assert_raise ActiveRecord::RecordInvalid do
      CustomerTier.new(customer: customers(:four), effective: Time.now, expiration: 1.month.from_now, tier: Tier.first).save!
    end
  end

  test 'ignores overlapping customer tiers for other customers' do
    assert CustomerTier.new(customer: customers(:four), effective: Time.now, expiration: 1.month.from_now, tier: Tier.first).save!
    assert CustomerTier.new(customer: customers(:three), effective: Time.now, expiration: 1.month.from_now, tier: Tier.first).save!
    assert CustomerTier.new(customer: customers(:two), effective: Time.now, expiration: 1.month.from_now, tier: Tier.first).save!
  end
end
