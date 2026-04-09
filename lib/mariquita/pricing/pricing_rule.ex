defmodule Mariquita.Pricing.PricingRule do
 @moduledoc """
  Behaviour defining a pricing rule applied to a single product line.

  Pricing rules belong to the **Pricing** bounded context. They encapsulate
  business logic that modifies how the final price of a product is calculated
  based on quantity, discounts, or promotional conditions.

  A pricing rule is responsible for two things:

    * determining whether it applies to a given product (`applies_to?/2`)
    * computing the final total for a line item (`calculate_total/3`)

  Rules are **pure**, **stateless**, and **composable**. They do not mutate the
  cart or line items. Instead, they receive the necessary data and return a
  computed price. This allows the `Pricing.Engine` to apply rules in a flexible
  and configurable way.

  Each rule is represented as a struct containing its configuration
  (e.g. product code, thresholds, discount values). This makes rules easy to
  parameterize and replace without modifying the checkout logic.
  """
  
  @callback applies_to?(rule :: struct(), product_code :: String.t()) :: boolean()

  @callback calculate_total(
              rule :: struct(),
              quantity :: pos_integer(),
              unit_price :: non_neg_integer()
            ) ::
              non_neg_integer()
end
