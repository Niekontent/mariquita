defmodule Mariquita.CheckoutAcceptanceTest do
  use ExUnit.Case

  alias Mariquita

  test "GR1, SR1, GR1, GR1, CF1 => 22.45" do
    cart =
      Mariquita.new_cart()
      |> Mariquita.scan("GR1")
      |> Mariquita.scan("SR1")
      |> Mariquita.scan("GR1")
      |> Mariquita.scan("GR1")
      |> Mariquita.scan("CF1")

    assert Mariquita.formatted_total(cart) == "£22.45"
  end

  test "GR1, GR1 => 3.11" do
    cart =
      Mariquita.new_cart()
      |> Mariquita.scan("GR1")
      |> Mariquita.scan("GR1")

    assert Mariquita.formatted_total(cart) == "£3.11"
  end

  test "SR1, SR1, GR1, SR1 => 16.61" do
    cart =
      Mariquita.new_cart()
      |> Mariquita.scan("SR1")
      |> Mariquita.scan("SR1")
      |> Mariquita.scan("GR1")
      |> Mariquita.scan("SR1")

    assert Mariquita.formatted_total(cart) == "£16.61"
  end

  test "GR1, CF1, SR1, CF1, CF1 => 30.57" do
    cart =
      Mariquita.new_cart()
      |> Mariquita.scan("GR1")
      |> Mariquita.scan("CF1")
      |> Mariquita.scan("SR1")
      |> Mariquita.scan("CF1")
      |> Mariquita.scan("CF1")

    assert Mariquita.formatted_total(cart) == "£30.57"
  end
end
