defmodule Grimoire.Feeds do
  @moduledoc """
  The Feeds context.
  """

  import Ecto.Query, warn: false

  alias Grimoire.Accounts.Scope
  alias Grimoire.Feeds.Feed
  alias Grimoire.Repo
  alias Phoenix.PubSub

  @doc """
  Subscribes to scoped notifications about any feed changes.

  The broadcast messages match the pattern:

    * {:created, %Feed{}}
    * {:updated, %Feed{}}
    * {:deleted, %Feed{}}

  """
  def subscribe(%Scope{} = scope) do
    key = scope.user.id

    PubSub.subscribe(Grimoire.PubSub, "user:#{key}:feeds")
  end

  @doc """
  Returns the list of feeds.

  ## Examples

      iex> list(scope)
      [%Feed{}, ...]

  """
  def list(%Scope{} = scope) do
    Repo.all(from feed in Feed, where: feed.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single feed.

  Raises `Ecto.NoResultsError` if the Feed does not exist.

  ## Examples

      iex> get!(123)
      %Feed{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(%Scope{} = scope, id) do
    Repo.get_by!(Feed, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a feed.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Feed{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(%Scope{} = scope, attrs) do
    with {:ok, feed = %Feed{}} <- do_create(attrs, scope) do
      broadcast(scope, {:created, feed})

      {:ok, feed}
    end
  end

  @doc """
  Updates a feed.

  ## Examples

      iex> update(feed, %{field: new_value})
      {:ok, %Feed{}}

      iex> update(feed, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Scope{} = scope, %Feed{} = feed, attrs) do
    true = feed.user_id == scope.user.id

    with {:ok, feed = %Feed{}} <- do_update(feed, attrs, scope) do
      broadcast(scope, {:updated, feed})

      {:ok, feed}
    end
  end

  @doc """
  Deletes a feed.

  ## Examples

      iex> delete(feed)
      {:ok, %Feed{}}

      iex> delete(feed)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Scope{} = scope, %Feed{} = feed) do
    true = feed.user_id == scope.user.id

    with {:ok, feed = %Feed{}} <- do_delete(feed) do
      broadcast(scope, {:deleted, feed})

      {:ok, feed}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking feed changes.

  ## Examples

      iex> change(feed)
      %Ecto.Changeset{data: %Feed{}}

  """
  def change(%Scope{} = scope, %Feed{} = feed, attrs \\ %{}) do
    true = feed.user_id == scope.user.id

    Feed.changeset(feed, attrs, scope)
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    PubSub.broadcast(Grimoire.PubSub, "user:#{key}:feeds", message)
  end

  defp do_create(attrs, scope) do
    %Feed{}
    |> Feed.changeset(attrs, scope)
    |> Repo.insert()
  end

  defp do_update(feed, attrs, scope) do
    feed
    |> Feed.changeset(attrs, scope)
    |> Repo.update()
  end

  defp do_delete(feed), do: Repo.delete(feed)
end
