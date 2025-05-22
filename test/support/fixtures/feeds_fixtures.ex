defmodule Grimoire.FeedsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Grimoire.Feeds` context.
  """

  @doc """
  Generate a feed.
  """
  def feed_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name"
      })

    {:ok, feed} = Grimoire.Feeds.create_feed(scope, attrs)
    feed
  end
end
