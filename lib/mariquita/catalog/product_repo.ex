defmodule Mariquita.Catalog.ProductRepo do
  @moduledoc """
  In‑memory repository providing access to products in the **Catalog** context.

  This module acts as the source of truth for product definitions used throughout
  the system. It exposes a simple lookup function, `get!/1`, which retrieves a
  `Product` struct by its product code.

  The repository is intentionally minimal and implemented as a static map for
  demonstration and testing purposes. In a real application, this module would
  serve as the abstraction layer over a database or external product service.

  Other bounded contexts, such as Checkout and Pricing, depend on this module
  to obtain immutable product data (name, code, base price) without needing to
  know how or where the catalog is stored.
  """
  
  alias Mariquita.Catalog.Product

  @products %{
    "GR1" => %Product{code: "GR1", name: "Green tea", unit_price: 311},
    "SR1" => %Product{code: "SR1", name: "Strawberries", unit_price: 500},
    "CF1" => %Product{code: "CF1", name: "Coffee", unit_price: 1123}
  }

  def get!(code) do
    Map.fetch!(@products, code)
  end
end
