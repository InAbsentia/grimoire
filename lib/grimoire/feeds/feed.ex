defmodule Grimoire.Feeds.Feed do
  use Ecto.Schema

  alias Grimoire.Accounts.User
  alias Grimoire.EctoTypes

  import Ecto.Changeset

  @allowed [:name, :source_type, :source_url]
  @required @allowed
  @source_types %{podcast: "Podcast feed", youtube: "Youtube"}
  @valid_source_url_schemes ["http", "https"]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "feeds" do
    field :name, :string
    field :source_type, Ecto.Enum, values: Map.keys(@source_types)
    field :source_url, EctoTypes.URI

    belongs_to :user, User

    timestamps type: :utc_datetime
  end

  @doc false
  def changeset(feed, attrs, user_scope) do
    feed
    |> cast(attrs, @allowed)
    |> validate_required(@required)
    |> validate_change(:source_url, &validate_source_url/2)
    |> put_change(:user_id, user_scope.user.id)
  end

  @doc false
  def source_types(), do: @source_types

  defp validate_source_url(:source_url, url) do
    {_, errors} =
      {url, []}
      |> validate_source_url_scheme()
      |> validate_source_url_host()
      |> validate_source_url_path()

    errors
  end

  defp validate_source_url_scheme({%URI{scheme: scheme} = url, errors}) do
    errors =
      if scheme not in @valid_source_url_schemes,
        do: [{:source_url, "scheme must be http or https"} | errors],
        else: errors

    {url, errors}
  end

  defp validate_source_url_host({%URI{host: nil} = url, errors}),
    do: {url, [{:source_url, "host is invalid"} | errors]}

  defp validate_source_url_host({%URI{host: host} = url, errors}) do
    labels = String.split(host, ".")

    errors =
      if String.length(host) <= 253 &&
           length(labels) > 1 &&
           Enum.all?(labels, &valid_host_label?/1),
         do: errors,
         else: [{:source_url, "host is invalid"} | errors]

    {url, errors}
  end

  defp validate_source_url_path({%URI{path: nil} = url, errors}),
    do: {url, [{:source_url, "path can't be blank"} | errors]}

  defp validate_source_url_path({%URI{} = url, errors}),
    do: {url, errors}

  # https://en.wikipedia.org/wiki/Hostname#Syntax
  # Label must not be longer than 63 bytes
  # First and last characters must be alphanumeric
  # Other characters must be alphanumeric or a hyphen (-)
  defp valid_host_label?(label) do
    byte_size(label) <= 63 &&
      label =~ ~r/^[a-zA-Z0-9].*/ &&
      label =~ ~r/^.*[a-zA-Z0-9]$/ &&
      label =~ ~r/^[a-zA-Z0-9-]*$/
  end
end
