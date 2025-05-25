defmodule GrimoireWeb.FeedLive.Index do
  use GrimoireWeb, :live_view

  alias Grimoire.Feeds

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Feeds
        <:actions>
          <.button variant="primary" navigate={~p"/feeds/new"}>
            <.icon name="hero-plus" /> New Feed
          </.button>
        </:actions>
      </.header>

      <.table
        id="feeds"
        rows={@streams.feeds}
        row_click={fn {_id, feed} -> JS.navigate(~p"/feeds/#{feed}") end}
      >
        <:col :let={{_id, feed}} label="Name">{feed.name}</:col>
        <:action :let={{_id, feed}}>
          <div class="sr-only">
            <.link navigate={~p"/feeds/#{feed}"}>Show</.link>
          </div>
          <.link navigate={~p"/feeds/#{feed}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, feed}}>
          <.link
            phx-click={JS.push("delete", value: %{id: feed.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Feeds.subscribe(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Feeds")
     |> stream(:feeds, Feeds.list(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    feed = Feeds.get!(socket.assigns.current_scope, id)
    {:ok, _} = Feeds.delete(socket.assigns.current_scope, feed)

    {:noreply, stream_delete(socket, :feeds, feed)}
  end

  @impl true
  def handle_info({type, %Grimoire.Feeds.Feed{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :feeds, Feeds.list(socket.assigns.current_scope), reset: true)}
  end
end
