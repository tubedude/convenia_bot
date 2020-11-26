defmodule CB.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      CBWeb.Endpoint,
      CB.Scheduler,
      CB.Employees
      # Starts a worker by calling: CB.Worker.start_link(arg)
      # {CB.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CB.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CBWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

# alias CB.Employees
# id = "69e955cb-e831-4f5f-8a4d-0027e7c457c0"
# old = Employees.list()
# Enum.count(old)
# Employees.find(id)
# Enum.count(Employees.list())
