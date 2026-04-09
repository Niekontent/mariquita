defmodule Mariquita.Catalog.Product do
  @moduledoc """
  Domain entity representing a product available in the supermarket catalog.

  A product belongs to the **Catalog** bounded context. It defines the static
  attributes of an item that can be scanned into a shopping cart:

    * `code` – unique product identifier (e.g. "GR1")
    * `name` – human‑readable product name
    * `unit_price` – base price in **cents** (integer), used by pricing rules

  Products are immutable within the checkout process. Other bounded contexts
  (such as Checkout or Pricing) only *read* product data; they never modify it.
  Any changes to product definitions (e.g. price updates) belong exclusively to
  the Catalog context.
  """

  @enforce_keys [:code, :name, :unit_price]
  defstruct [:code, :name, :unit_price]

  @type t :: %__MODULE__{
          code: String.t(),
          name: String.t(),
          unit_price: non_neg_integer()
        }
end
