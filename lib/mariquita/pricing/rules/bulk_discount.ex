defmodule Mariquita.Pricing.Rules.BulkDiscount do
  @moduledoc """
  Pricing rule applying a discounted unit price when a quantity threshold is met.

  This rule activates when the number of purchased units for a given product
  reaches or exceeds the configured `threshold`. Once triggered, **all units**
  of that product are priced at the discounted `discount_price` (in cents).

  Example:

      threshold: 3
      discount_price: 450

      quantity: 1 → 1 × regular price
      quantity: 2 → 2 × regular price
      quantity: 3 → 3 × 450
      quantity: 4 → 4 × 450

  This rule is commonly used for volume‑based promotions such as “3 or more for
  a lower price”. It is fully parameterized and does not require any changes to
  the pricing engine when new bulk discounts are introduced.
  """

  @behaviour Mariquita.Pricing.PricingRule

  defstruct [:product_code, :threshold, :discount_price]

  @impl true
  def applies_to?(%__MODULE__{product_code: rule_code}, scanned_code),
    do: scanned_code == rule_code

  @impl true
  def calculate_total(%__MODULE__{threshold: t, discount_price: d}, quantity, unit_price)
      when quantity > 0 do
    if quantity >= t do
      d * quantity
    else
      unit_price * quantity
    end
  end
end
