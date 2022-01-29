require 'test_helper'

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  test 'saves charge succeeded events' do
    assert_difference -> { ExternalEvent.count } => 1, -> { Charge.count } => 1 do
      Sidekiq::Testing.inline! do
        post stripe_webhooks_url, **generate_body('stripe-webhook-examples/charge.succeeded.json')
      end
    end
  end

  test 'saves charge refunded events' do
    body = generate_body('stripe-webhook-examples/charge.refunded.json')
    assert_difference -> { ExternalEvent.count } => 1, -> { Charge.count } => 1 do
      Sidekiq::Testing.inline! do
        post stripe_webhooks_url, **body
      end
    end
    event = Stripe::Event.construct_from(body[:params])
    assert Charge.find_by(
      stripe_id: event.data.object.id
    ).refunded
  end

  test 'saves any event' do
    assert_difference -> { ExternalEvent.count } => 1, -> { Charge.count } => 0 do
      Sidekiq::Testing.inline! do
        post stripe_webhooks_url, **generate_body('stripe-webhook-examples/unhandled.event.json')
      end
    end
  end

  test 'associates events with customer' do
    body = generate_body('stripe-webhook-examples/charge.refunded.json')
    Sidekiq::Testing.inline! do
      post stripe_webhooks_url, **body
    end
    event = Stripe::Event.construct_from(body[:params])
    charge = Charge.find_by(
      stripe_id: event.data.object.id
    )
    assert_equal customers(:one).id, charge.customer.id
  end

  private

  def generate_body(payload_path)
    payload = file_fixture_json(payload_path)
    header = generate_header(payload.to_json)
    {
      headers: { 'HTTP_STRIPE_SIGNATURE': header },
      params:  payload,
      as:      :json
    }
  end

  # Modified from Stripe tests https://github.com/stripe/stripe-ruby/blob/master/test/stripe/webhook_test.rb#L15
  def generate_header(payload)
    timestamp = Time.now
    Stripe::Webhook::Signature.generate_header(
      timestamp,
      Stripe::Webhook::Signature.compute_signature(timestamp, payload, StripeHelper::Webhook.endpoint_secret),
      scheme: Stripe::Webhook::Signature::EXPECTED_SCHEME
    )
  end
end
