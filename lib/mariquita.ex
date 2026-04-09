defmodule Mariquita do
  @moduledoc """
  Public API module for the supermarket checkout system.

  This module exposes the high‑level API used to interact with the checkout
  workflow: creating carts, scanning products, and computing totals. Internally,
  it delegates to the Catalog, Checkout, and Pricing bounded contexts, but hides
  their complexity behind a simple and ergonomic interface.

  ## Scanning products

  Two variants are provided for scanning products into the cart:

  ### `scan/2` — safe, non‑raising variant

      scan(cart, product_code) :: {:ok, cart} | {:error, :unknown_product}

  This function attempts to look up the product in the catalog and add it to the
  cart. It **never raises exceptions**. Instead, it returns a tagged tuple
  indicating success or failure.

  Use this variant when:

    * you want explicit error handling,
    * you are writing domain logic or tests,
    * an unknown product is a normal domain case.

  ### `scan!/2` — raising, convenient variant

      scan!(cart, product_code) :: cart | no_return()

  This function behaves like `scan/2` on success, but **raises an
  `ArgumentError`** if the product does not exist in the catalog.

  Use this variant when:

    * you want clean pipelines,
    * you are writing examples, scripts, or REPL‑style code,
    * an unknown product should be treated as a programmer error.

  This mirrors the common Elixir convention (`File.read/1` vs `File.read!/1`,
  `Map.fetch/2` vs `Map.fetch!/2`, etc.).

  ## Pricing rules

  The default pricing rules applied by the checkout system are defined internally
  and injected automatically when a new cart is created. These rules implement the
  `Mariquita.Pricing.PricingRule` behaviour and encapsulate the supermarket’s
  promotional policy.

  ## Examples

  Using the raising variant for clean pipelines:

      cart =
        Mariquita.new_cart()
        |> Mariquita.scan!("GR1")
        |> Mariquita.scan!("SR1")
        |> Mariquita.scan!("GR1")

      Mariquita.formatted_total(cart)
      #=> "£16.61"

  Using the safe variant for explicit error handling:

      case Mariquita.scan(cart, "NOPE") do
        {:ok, cart} ->
          # product added

        {:error, :unknown_product} ->
          # show message to the user
      end
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

  @doc """
  Safely scans a product into the cart.

  This function attempts to look up the product in the catalog and, if found,
  adds it to the cart. It never raises exceptions. Instead, it returns a tagged
  tuple indicating success or failure.

  ## Returns

    * `{:ok, cart}` — when the product exists and was added successfully
    * `{:error, :unknown_product}` — when the product code does not exist in the catalog

  This variant is recommended for use in domain logic, tests, and any code that
  needs explicit control over error handling without interrupting the execution
  flow.

  ## Examples

      iex> {:ok, cart} = Mariquita.scan(cart, "GR1")
      iex> Mariquita.scan(cart, "NOPE")
      {:error, :unknown_product}

  """

  def scan(%Cart{} = cart, product_code) do
    case ProductRepo.get(product_code) do
      {:ok, product} ->
        {:ok, Cart.add_item(cart, product)}

      :error ->
        {:error, :unknown_product}
    end
  end

  @doc """
  Scans a product into the cart, raising an exception on failure.

  This is the bang (`!`) variant of `scan/2`. It behaves the same on success,
  returning the updated cart, but raises an `ArgumentError` if the product code
  does not exist in the catalog.

  This variant is convenient for pipelines, scripts, and examples where explicit
  error handling would add noise, and where an unknown product should be treated
  as a programmer error rather than a normal domain case.

  ## Raises

    * `ArgumentError` — if the product code is not found in the catalog

  ## Examples

      iex> cart =
      ...>   Mariquita.new_cart()
      ...>   |> Mariquita.scan!("GR1")
      ...>   |> Mariquita.scan!("SR1")

      iex> Mariquita.scan!(cart, "NOPE")
      ** (ArgumentError) Unknown product code: NOPE

  """

  def scan!(%Cart{} = cart, product_code) do
    case scan(cart, product_code) do
      {:ok, cart} ->
        cart

      {:error, :unknown_product} ->
        raise ArgumentError, "Unknown product code: #{product_code}"
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
