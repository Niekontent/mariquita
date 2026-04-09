defmodule Mariquita.Pricing.Rules.BuyOneGetOneFree do
  @moduledoc """
  Pricing rule implementing a classic *Buy One, Get One Free* promotion.

  This rule applies to a single product identified by its `product_code`. When
  active, every second unit of the product is free. For example:

      quantity: 1 → pay for 1
      quantity: 2 → pay for 1
      quantity: 3 → pay for 2
      quantity: 4 → pay for 2
      ...

  The rule is stateless and fully parameterized through its struct fields,
  allowing different products to participate in BOGOF promotions without
  modifying the pricing engine or checkout logic.

  The rule does not modify line items or cart state. It simply computes the
  total price for the given quantity and unit price.
  """

  @behaviour Mariquita.Pricing.PricingRule

  defstruct [:product_code]

  @impl true
  def applies_to?(%__MODULE__{product_code: rule_code}, scanned_code),
    do: scanned_code == rule_code

  @impl true
  def calculate_total(_rule, quantity, unit_price) when quantity > 0 do
    payable = div(quantity + 1, 2)
    payable * unit_price
  end
end
