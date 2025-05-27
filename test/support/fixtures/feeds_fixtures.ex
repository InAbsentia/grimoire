defmodule Grimoire.FeedsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Grimoire.Feeds` context.
  """

  @doc """
  Generate a feed.
  """
  def feed_fixture(scope, attrs \\ %{}) do
    {:ok, feed} = Grimoire.Feeds.create(scope, valid_feed_attrs(attrs))

    feed
  end

  def valid_feed_attrs(attrs \\ %{}) do
    Enum.into(
      attrs,
      %{name: "some name", source_type: :podcast, source_url: unique_url()}
    )
  end

  defp unique_url(), do: "https://example.com/#{System.unique_integer([:positive])}"
end
