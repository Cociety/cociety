require 'stripe_mock'

module StripeSupport
  def stripe_helper
    StripeMock.create_test_helper
  end

  def before_setup
    StripeMock.start
    super
  end

  def after_teardown
    StripeMock.stop
    super
  end
end
