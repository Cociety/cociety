class StripeHelper::Webhook
  def self.endpoint_secret
    Rails.application.credentials.stripe[:signing_secret]
  end
end
