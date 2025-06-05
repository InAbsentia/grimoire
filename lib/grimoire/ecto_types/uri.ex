defmodule Grimoire.EctoTypes.URI do
  @moduledoc """
  A custom Ecto type for storing URIs.
  """

  use Ecto.Type

  @impl true
  def type, do: :map

  @impl true
  def cast(uri) when is_binary(uri), do: {:ok, URI.parse(uri)}
  def cast(%URI{} = uri), do: {:ok, uri}
  def cast(_), do: :error

  @impl true
  def load(data) when is_map(data) do
    data = for {key, val} <- data, do: {String.to_existing_atom(key), val}

    {:ok, struct!(URI, data)}
  end

  @impl true
  def dump(%URI{} = uri), do: {:ok, Map.from_struct(uri)}
  def dump(_), do: :error
end
