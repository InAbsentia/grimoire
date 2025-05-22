defmodule Grimoire.Feeds.Feed do
  use Ecto.Schema

  alias Grimoire.Accounts.User

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "feeds" do
    field :name, :string

    belongs_to :user, User

    timestamps type: :utc_datetime
  end

  @doc false
  def changeset(feed, attrs, user_scope) do
    feed
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_change(:user_id, user_scope.user.id)
  end
end
