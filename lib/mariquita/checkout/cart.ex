defmodule Mariquita.Checkout.Cart do
  @moduledoc """
  Aggregate root representing a customer's shopping cart.

  The **Checkout** bounded context is responsible for collecting scanned products
  and preparing them for price calculation. A cart contains:

    * a collection of `LineItem` structs, grouped by product code
    * a list of pricing rules that will later be applied by the Pricing Engine

  The cart itself does not perform any pricing logic. Its responsibility is
  limited to maintaining the current state of scanned items. Pricing is handled
  exclusively by the `Mariquita.Pricing.Engine`.

  Products added to the cart are full `Product` structs from the **Catalog**
  context. This ensures that the cart always contains complete domain data
  (e.g. name, base price), while remaining immutable with respect to catalog
  changes.

  The cart is an append‑only structure: adding an item increases its quantity,
  but never mutates product definitions or pricing rules.
  """

  alias Mariquita.Checkout.LineItem
  alias Mariquita.Catalog.Product

  @enforce_keys [:items, :rules]
  defstruct items: %{}, rules: []

  @type t :: %__MODULE__{
          items: %{optional(String.t()) => LineItem.t()},
          rules: list(struct())
        }

  def new(rules \\ []) do
    %__MODULE__{items: %{}, rules: rules}
  end

  @doc """
  Adds a product to the cart.
  """
  def add_item(%__MODULE__{} = cart, %Product{code: code} = product) do
    items =
      Map.update(
        cart.items,
        code,
        %LineItem{product: product, quantity: 1},
        fn %LineItem{} = li ->
          %LineItem{li | quantity: li.quantity + 1}
        end
      )

    %__MODULE__{cart | items: items}
  end

  def line_items(%__MODULE__{items: items}) do
    Map.values(items)
  end
end
