defmodule Grimoire.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GrimoireWeb.Telemetry,
      Grimoire.Repo,
      {DNSCluster, query: Application.get_env(:grimoire, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Grimoire.PubSub},
      # Start a worker by calling: Grimoire.Worker.start_link(arg)
      # {Grimoire.Worker, arg},
      # Start to serve requests, typically the last entry
      GrimoireWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Grimoire.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GrimoireWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
