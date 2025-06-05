defmodule GrimoireWeb.FeedLive.Show do
  use GrimoireWeb, :live_view

  alias Grimoire.Feeds
  alias Grimoire.Feeds.Feed

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@feed.name}
        <:subtitle>This is a feed record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/feeds"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/feeds/#{@feed}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit feed
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@feed.name}</:item>
        <:item title="Source Type">{source_type(@feed)}</:item>
        <:item title="Source URL">{@feed.source_url}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Feeds.subscribe(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Feed")
     |> assign(:feed, Feeds.get!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Grimoire.Feeds.Feed{id: id} = feed},
        %{assigns: %{feed: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :feed, feed)}
  end

  def handle_info(
        {:deleted, %Grimoire.Feeds.Feed{id: id}},
        %{assigns: %{feed: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current feed was deleted.")
     |> push_navigate(to: ~p"/feeds")}
  end

  def handle_info({type, %Grimoire.Feeds.Feed{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end

  defp source_type(%Feed{source_type: type}),
    do: Map.get(Feed.source_types(), type)
end
