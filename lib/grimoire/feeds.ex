defmodule Grimoire.Feeds do
  @moduledoc """
  The Feeds context.
  """

  import Ecto.Query, warn: false

  alias Grimoire.Accounts.Scope
  alias Grimoire.Feeds.Feed
  alias Grimoire.Repo

  @doc """
  Subscribes to scoped notifications about any feed changes.

  The broadcast messages match the pattern:

    * {:created, %Feed{}}
    * {:updated, %Feed{}}
    * {:deleted, %Feed{}}

  """
  def subscribe_feeds(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Grimoire.PubSub, "user:#{key}:feeds")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Grimoire.PubSub, "user:#{key}:feeds", message)
  end

  @doc """
  Returns the list of feeds.

  ## Examples

      iex> list_feeds(scope)
      [%Feed{}, ...]

  """
  def list_feeds(%Scope{} = scope) do
    Repo.all(from feed in Feed, where: feed.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single feed.

  Raises `Ecto.NoResultsError` if the Feed does not exist.

  ## Examples

      iex> get_feed!(123)
      %Feed{}

      iex> get_feed!(456)
      ** (Ecto.NoResultsError)

  """
  def get_feed!(%Scope{} = scope, id) do
    Repo.get_by!(Feed, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a feed.

  ## Examples

      iex> create_feed(%{field: value})
      {:ok, %Feed{}}

      iex> create_feed(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_feed(%Scope{} = scope, attrs) do
    with {:ok, feed = %Feed{}} <-
           %Feed{}
           |> Feed.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, feed})
      {:ok, feed}
    end
  end

  @doc """
  Updates a feed.

  ## Examples

      iex> update_feed(feed, %{field: new_value})
      {:ok, %Feed{}}

      iex> update_feed(feed, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_feed(%Scope{} = scope, %Feed{} = feed, attrs) do
    true = feed.user_id == scope.user.id

    with {:ok, feed = %Feed{}} <-
           feed
           |> Feed.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, feed})
      {:ok, feed}
    end
  end

  @doc """
  Deletes a feed.

  ## Examples

      iex> delete_feed(feed)
      {:ok, %Feed{}}

      iex> delete_feed(feed)
      {:error, %Ecto.Changeset{}}

  """
  def delete_feed(%Scope{} = scope, %Feed{} = feed) do
    true = feed.user_id == scope.user.id

    with {:ok, feed = %Feed{}} <-
           Repo.delete(feed) do
      broadcast(scope, {:deleted, feed})
      {:ok, feed}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking feed changes.

  ## Examples

      iex> change_feed(feed)
      %Ecto.Changeset{data: %Feed{}}

  """
  def change_feed(%Scope{} = scope, %Feed{} = feed, attrs \\ %{}) do
    true = feed.user_id == scope.user.id

    Feed.changeset(feed, attrs, scope)
  end
end
