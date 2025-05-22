defmodule GrimoireWeb.FeedLive.Form do
  use GrimoireWeb, :live_view

  alias Grimoire.Feeds
  alias Grimoire.Feeds.Feed

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage feed records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="feed-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Feed</.button>
          <.button navigate={return_path(@current_scope, @return_to, @feed)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    feed = Feeds.get_feed!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Feed")
    |> assign(:feed, feed)
    |> assign(:form, to_form(Feeds.change_feed(socket.assigns.current_scope, feed)))
  end

  defp apply_action(socket, :new, _params) do
    feed = %Feed{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Feed")
    |> assign(:feed, feed)
    |> assign(:form, to_form(Feeds.change_feed(socket.assigns.current_scope, feed)))
  end

  @impl true
  def handle_event("validate", %{"feed" => feed_params}, socket) do
    changeset = Feeds.change_feed(socket.assigns.current_scope, socket.assigns.feed, feed_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"feed" => feed_params}, socket) do
    save_feed(socket, socket.assigns.live_action, feed_params)
  end

  defp save_feed(socket, :edit, feed_params) do
    case Feeds.update_feed(socket.assigns.current_scope, socket.assigns.feed, feed_params) do
      {:ok, feed} ->
        {:noreply,
         socket
         |> put_flash(:info, "Feed updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, feed)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_feed(socket, :new, feed_params) do
    case Feeds.create_feed(socket.assigns.current_scope, feed_params) do
      {:ok, feed} ->
        {:noreply,
         socket
         |> put_flash(:info, "Feed created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, feed)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _feed), do: ~p"/feeds"
  defp return_path(_scope, "show", feed), do: ~p"/feeds/#{feed}"
end
