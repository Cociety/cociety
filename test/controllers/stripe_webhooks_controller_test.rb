require 'test_helper'

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  test 'saves charge succeeded events' do
    assert_difference -> { ExternalEvent.count } => 1, -> { Charge.count } => 1 do
      post stripe_webhooks_url, params: file_fixture_json('stripe-webhook-examples/charge.succeeded'), as: :json
    end
  end

  test 'saves charge refunded events' do
    json = file_fixture_json('stripe-webhook-examples/charge.refunded')
    assert_difference -> { ExternalEvent.count } => 1, -> { Charge.count } => 1 do
      post stripe_webhooks_url, params: json, as: :json
    end
    assert Charge.find([ExternalEntitySource.Stripe.id, json['id'], json['data']['object']['id']]).refunded
  end

  test 'saves any event' do
    assert_difference -> { ExternalEvent.count } => 1, -> { Charge.count } => 0 do
      post stripe_webhooks_url, params: file_fixture_json('stripe-webhook-examples/unhandled.event'), as: :json
    end
  end
end
