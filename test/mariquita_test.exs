defmodule Mariquita.CheckoutAcceptanceTest do
  use ExUnit.Case

  alias Mariquita

  test "GR1, SR1, GR1, GR1, CF1 => 22.45" do
    cart =
      Mariquita.new_cart()
      |> scan_ok("GR1")
      |> scan_ok("SR1")
      |> scan_ok("GR1")
      |> scan_ok("GR1")
      |> scan_ok("CF1")

    assert Mariquita.formatted_total(cart) == "£22.45"
  end

  test "GR1, GR1 => 3.11" do
    cart =
      Mariquita.new_cart()
      |> scan_ok("GR1")
      |> scan_ok("GR1")

    assert Mariquita.formatted_total(cart) == "£3.11"
  end

  test "SR1, SR1, GR1, SR1 => 16.61" do
    cart =
      Mariquita.new_cart()
      |> scan_ok("SR1")
      |> scan_ok("SR1")
      |> scan_ok("GR1")
      |> scan_ok("SR1")

    assert Mariquita.formatted_total(cart) == "£16.61"
  end

  test "GR1, CF1, SR1, CF1, CF1 => 30.57" do
    cart =
      Mariquita.new_cart()
      |> scan_ok("GR1")
      |> scan_ok("CF1")
      |> scan_ok("SR1")
      |> scan_ok("CF1")
      |> scan_ok("CF1")

    assert Mariquita.formatted_total(cart) == "£30.57"
  end

  # test "returns error when scanning unknown product" do
  #   cart = Mariquita.new_cart()

  #   assert {:error, :unknown_product} = Mariquita.scan(cart, "XYZ")
  # end

  test "scan/2 returns {:ok, cart} when product exists" do
    cart = Mariquita.new_cart()
    assert {:ok, updated} = Mariquita.scan(cart, "GR1")
    assert updated != cart
  end

  test "scan/2 returns {:error, :unknown_product} when product does not exist" do
    cart = Mariquita.new_cart()
    assert {:error, :unknown_product} = Mariquita.scan(cart, "NOPE")
  end

  test "scan!/2 returns cart when product exists" do
    cart = Mariquita.new_cart()
    updated = Mariquita.scan!(cart, "GR1")
    assert updated != cart
  end

  test "scan!/2 raises when product does not exist" do
    cart = Mariquita.new_cart()

    assert_raise ArgumentError, "Unknown product code: NOPE", fn ->
      Mariquita.scan!(cart, "NOPE")
    end
  end

  defp scan_ok(cart, code) do
    {:ok, cart} = Mariquita.scan(cart, code)
    cart
  end
end
