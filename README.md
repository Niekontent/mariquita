# 🛒 Mariquita — Supermarket Checkout System
A Domain‑Driven Design architecture for catalog, checkout, and pricing

Mariquita is a supermarket checkout system implemented in Elixir and structured around Domain‑Driven Design (DDD) principles.
The project is divided into three clear bounded contexts:

**Catalog** — product definitions

**Checkout** — cart and scanning workflow

**Pricing** — promotional rules and price calculation

Each context has a well‑defined responsibility and communicates with others through explicit, stable interfaces.

## 🧩 Domain Architecture

+------------------+       +------------------+       +------------------+
|     Catalog      |       |     Checkout     |       |      Pricing     |
|------------------|       |------------------|       |------------------|
| Product          | ----> | Cart             | ----> | Pricing Engine   |
| ProductRepo      |       | LineItem         |       | PricingRule      |
+------------------+       +------------------+       | Rules/*          |
                                                      +------------------+

## ✔️ Catalog
The Catalog context contains static product information:

- `Product` — domain entity

- `ProductRepo` — in‑memory repository (can be replaced with a database later)

Catalog is the **source of truth** for product data.
Checkout and Pricing **only read** from this context.

## ✔️ Checkout
Responsible for:

- creating and managing the shopping cart (`Cart`)

- scanning products (`scan/2`)

- grouping identical products into `LineItem`

Checkout **does not perform any pricing logic.**
Its job is to prepare structured data for the Pricing context.

## ✔️ Pricing
Responsible for:

- selecting the correct pricing rule for each product

- computing the final total

- defining the supermarket’s promotional policy

Components:

- `PricingRule` — behaviour for all pricing rules

- `Engine` — orchestrates rule execution

- `Rules/*` — concrete promotions:

  - Buy One Get One Free

  - Bulk Discount

  - Percentage Discount

Pricing is **pure and stateless** — it never mutates the cart or products.

## 🧠 Data Flow
1. A client creates a cart:

```elixir
cart = Mariquita.new_cart()
```

2. Products are scanned:

```elixir
cart = Mariquita.scan(cart, "GR1")
```

3. Checkout fetches the product from Catalog and updates the cart.

4. When computing the total:
```elixir
Mariquita.formatted_total(cart)
```

The Pricing Engine:

- iterates through all `LineItem`s

- finds the rule that applies

- delegates price calculation to the rule

- accumulates the final total

## 🧮 Example
Input:
```elixir
GR1, SR1, GR1, GR1, CF1
```
Promotions applied:

- GR1 → Buy One Get One Free

- SR1 → Bulk Discount (3+ cheaper)

- CF1 → Percentage Discount (2/3 price when buying 3+)

Final result:
```elixir
£22.45
```

## 🧱 Directory Structure

```
lib/mariquita/
  catalog/
    product.ex
    product_repo.ex

  checkout/
    cart.ex
    line_item.ex

  pricing/
    pricing_rule.ex
    engine.ex
    rules/
      buy_one_get_one_free.ex
      bulk_discount.ex
      percentage_discount.ex

  mariquita.ex
```

## 🎯 Design Principles
- **DDD‑aligned** — clear bounded contexts

- **Pure functions** — Pricing Engine and rules are stateless

- **Configurable promotions** — `default_pricing_rules/0` is the central place for pricing policy

- **Immutable domain data** — Cart and Pricing never modify products

- **Stable public API** — the `Mariquita` module acts as a façade

## 🧪 Tests
The project includes acceptance tests that verify:

- correct application of promotions

- integration between contexts

- currency formatting


