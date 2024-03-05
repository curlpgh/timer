defmodule Timer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TimerWeb.Telemetry,
      # Start the Ecto repository
      Timer.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Timer.PubSub},
      # Start Finch
      {Finch, name: Timer.Finch},
      # Start the Endpoint (http/https)
      TimerWeb.Endpoint
      # Start a worker by calling: Timer.Worker.start_link(arg)
      # {Timer.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Timer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TimerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
