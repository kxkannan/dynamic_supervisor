defmodule SimpleQueue.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [{QueueManager, %{}}]
    opts = [strategy: :one_for_one, name: QueueManager.Supervisor]

    options = [
      name: SimpleQueue.Supervisor,
      strategy: :one_for_one
    ]

    DynamicSupervisor.start_link(options)
    Supervisor.start_link(children, opts)
  end
end
