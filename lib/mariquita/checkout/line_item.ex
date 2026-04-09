defmodule Mariquita.Checkout.LineItem do
  @moduledoc """
  Represents a single entry in the shopping cart.

  A `LineItem` belongs to the **Checkout** bounded context and models the
  customer's intent to purchase a specific product in a given quantity.

  Each line item contains:

    * the full `Product` struct from the **Catalog** context
    * the accumulated quantity of that product scanned into the cart

  `LineItem` does not perform any pricing logic. Its responsibility is purely
  structural: it groups identical products together so that pricing rules can be
  applied efficiently by the `Mariquita.Pricing.Engine`.

  Line items are created and updated exclusively by the `Cart` aggregate. They
  are not meant to be constructed or mutated directly outside of the Checkout
  context.
  """

  @enforce_keys [:product, :quantity]
  defstruct [:product, :quantity]

  @type t :: %__MODULE__{
          product: Mariquita.Catalog.Product.t(),
          quantity: pos_integer()
        }
end
