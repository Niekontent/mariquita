defmodule Mariquita.Pricing.Rules.PercentageDiscount do
  @moduledoc """
  Pricing rule applying a percentage‑based discount when a quantity threshold is met.

  When the number of purchased units reaches the configured `threshold`, the
  unit price is multiplied by the given `percentage` (e.g. `2/3` for a 33%
  discount). The discounted unit price is then applied to **all units** of the
  product.

  Example:

      threshold: 3
      percentage: 2/3

      quantity: 1 → 1 × regular price
      quantity: 2 → 2 × regular price
      quantity: 3 → 3 × (regular price × 2/3)
      quantity: 4 → 4 × (regular price × 2/3)

  This rule is useful for promotions such as “Buy 3 or more and get 33% off”.
  It is fully parameterized and does not require changes to the pricing engine
  when new percentage‑based promotions are added.

  The rule is pure and stateless; it only computes totals based on the provided
  data.
  """
  @behaviour Mariquita.Pricing.PricingRule

  defstruct [:product_code, :threshold, :percentage]

  @impl true
  def applies_to?(%__MODULE__{product_code: rule_code}, scanned_code),
    do: scanned_code == rule_code

  @impl true
  def calculate_total(%__MODULE__{threshold: t, percentage: p}, quantity, unit_price)
      when quantity >= t do
    discounted_unit = unit_price * p
    round(discounted_unit * quantity)
  end

  def calculate_total(_rule, quantity, unit_price) do
    unit_price * quantity
  end
end
