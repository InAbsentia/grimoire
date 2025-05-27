defmodule Grimoire.Feeds.Feed do
  use Ecto.Schema

  alias Grimoire.Accounts.User

  import Ecto.Changeset

  @allowed [:name, :source_type, :source_url]
  @required @allowed
  @source_types %{podcast: "Podcast feed", youtube: "Youtube"}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "feeds" do
    field :name, :string
    field :source_type, Ecto.Enum, values: Map.keys(@source_types)
    field :source_url, :string

    belongs_to :user, User

    timestamps type: :utc_datetime
  end

  @doc false
  def changeset(feed, attrs, user_scope) do
    feed
    |> cast(attrs, @allowed)
    |> validate_required(@required)
    |> put_change(:user_id, user_scope.user.id)
  end

  @doc false
  def source_types(), do: @source_types
end
