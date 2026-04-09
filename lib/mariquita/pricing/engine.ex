defmodule Mariquita.Pricing.Engine do
  @moduledoc """
  Core component responsible for applying pricing rules to the contents of a cart.

  The Pricing Engine belongs to the **Pricing** bounded context. Its role is to
  compute the final total for a shopping cart by evaluating each line item
  against the configured pricing rules.

  The engine does not contain any business rules itself. Instead, it orchestrates
  rule execution by:

    * iterating over all line items in the cart
    * selecting the pricing rule that applies to each product
    * delegating price calculation to the rule's `calculate_total/3` callback
    * accumulating the final total in cents

  The engine is intentionally **stateless** and **pure**. It does not mutate the
  cart, products, or rules. All domain logic resides inside individual pricing
  rule modules implementing the `Mariquita.Pricing.PricingRule`
  behaviour.

  This design allows pricing strategies to be easily extended or replaced without
  modifying the checkout flow. New rules can be introduced simply by adding new
  modules and including them in the cart's rule list.
  """

  alias Mariquita.Checkout.Cart

  def total(%Cart{} = cart, rules) do
    cart
    |> Cart.line_items()
    |> Enum.reduce(0, fn line_item, acc ->
      product = line_item.product
      rule = find_rule(rules, product.code)

      rule_module = rule.__struct__

      line_total =
        rule_module.calculate_total(
          rule,
          line_item.quantity,
          product.unit_price
        )

      acc + line_total
    end)
  end

  defp find_rule(rules, product_code) do
    Enum.find(rules, fn rule ->
      rule.__struct__.applies_to?(rule, product_code)
    end) ||
      raise "No pricing rule for product #{product_code}"
  end
end
