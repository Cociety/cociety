class StripeHelper::PaymentMethod
  #
  # StripeHelper::PaymentMethod.create_card("cus_123", {
  #      number: "4111111111111111",
  #      exp_month: 11,
  #      exp_year: 2021,
  #      cvc: "314"
  # })
  # https://stripe.com/docs/api/tokens/create_card
  # https://stripe.com/docs/api/cards/create
  #
  def self.create_card(stripe_id, card_args)
    token = Stripe::Token.create({
                                   card: card_args
                                 }).id
    Stripe::Customer.create_source(
      stripe_id,
      { source: token }
    )
  end

  def self.get_cards(stripe_id)
    Stripe::PaymentMethod.list({
                                 customer: stripe_id,
                                 type:     'card'
                               })['data']
  end
end
