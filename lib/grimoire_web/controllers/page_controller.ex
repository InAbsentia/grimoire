defmodule GrimoireWeb.PageController do
  use GrimoireWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
