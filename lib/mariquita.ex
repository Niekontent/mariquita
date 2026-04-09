defmodule Mariquita do
  @moduledoc """
  Public API for the supermarket checkout system.

  This module acts as the entry point to the **Checkout** bounded context. It
  provides a simple, high‑level interface for creating carts, scanning products,
  and computing totals, while delegating all domain logic to the appropriate
  contexts:

    * product lookup is handled by the **Catalog** context
    * cart state is managed by the **Checkout** context
    * price calculation is performed by the **Pricing** context

  The goal of this module is to offer a clean and minimal surface for clients
  such as CLI tools, web controllers, or automated tests. It hides internal
  details such as pricing rule configuration, cart structure, and rule
  evaluation mechanics.

  Typical usage:

      cart =
        Mariquita.new_cart()
        |> Mariquita.scan("GR1")
        |> Mariquita.scan("SR1")

      Mariquita.formatted_total(cart)
      #=> "£8.11"

  The module is intentionally lightweight and delegates all business logic to
  specialized components, keeping the public API stable and easy to use.

  ## Pricing rules

  The function `default_pricing_rules/0` (private) defines the supermarket’s
  default promotional policy. It returns a list of pricing rule structs that
  the checkout system applies automatically when a new cart is created.
  """

  alias Mariquita.Catalog.ProductRepo
  alias Mariquita.Checkout.Cart
  alias Mariquita.Pricing.Engine
  alias Mariquita.Pricing.Rules.BulkDiscount
  alias Mariquita.Pricing.Rules.BuyOneGetOneFree
  alias Mariquita.Pricing.Rules.PercentageDiscount

  @type cart :: Cart.t()

  def new_cart(rules \\ default_pricing_rules()) do
    %Cart{items: %{}, rules: rules}
  end

  def scan(%Cart{} = cart, product_code) do
    case ProductRepo.get(product_code) do
      {:ok, product} ->
        {:ok, Cart.add_item(cart, product)}

      :error ->
        {:error, :unknown_product}
    end
  end

  def total(%Cart{rules: rules} = cart) do
    Engine.total(cart, rules)
  end

  def formatted_total(cart) do
    cart
    |> total()
    |> to_currency()
  end

  defp default_pricing_rules do
    [
      %BuyOneGetOneFree{product_code: "GR1"},
      %BulkDiscount{product_code: "SR1", threshold: 3, discount_price: 450},
      %PercentageDiscount{product_code: "CF1", threshold: 3, percentage: 2 / 3}
    ]
  end

  defp to_currency(amount_in_cents) do
    pounds = div(amount_in_cents, 100)
    cents = rem(amount_in_cents, 100) |> Integer.to_string() |> String.pad_leading(2, "0")
    "£#{pounds}.#{cents}"
  end
end
