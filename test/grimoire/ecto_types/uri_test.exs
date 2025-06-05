defmodule Grimoire.EctoTypes.URITest do
  use ExUnit.Case, async: true

  alias Grimoire.EctoTypes

  @uri_string "http://example.com/hello"

  describe "cast/1" do
    test "converts a string to a URI struct" do
      assert EctoTypes.URI.cast(@uri_string) == {:ok, URI.parse(@uri_string)}
    end

    test "returns a URI unchanged" do
      uri = URI.parse(@uri_string)

      assert EctoTypes.URI.cast(uri) == {:ok, uri}
    end

    test "returns :error when value is not a string" do
      assert EctoTypes.URI.cast(5) == :error
      assert EctoTypes.URI.cast(6.2) == :error
      assert EctoTypes.URI.cast(%{}) == :error
      assert EctoTypes.URI.cast([]) == :error
    end
  end

  describe "load/1" do
    test "loads a map from the database" do
      uri = URI.parse(@uri_string)
      map = uri |> Map.from_struct() |> Map.new(fn {key, val} -> {to_string(key), val} end)

      assert EctoTypes.URI.load(map) == {:ok, uri}
    end
  end

  describe "dump/1" do
    test "dumps a URI struct to a map" do
      uri = URI.parse(@uri_string)

      assert EctoTypes.URI.dump(uri) == {:ok, Map.from_struct(uri)}
    end

    test "returns :error when value is not a URI struct" do
      assert EctoTypes.URI.dump(5) == :error
      assert EctoTypes.URI.dump(6.2) == :error
      assert EctoTypes.URI.dump(%{}) == :error
      assert EctoTypes.URI.dump([]) == :error
    end
  end
end
