defmodule QueueManager do
  use GenServer

  require Logger

  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def start_children(num) do
    GenServer.call(__MODULE__, {:start_children, num})
  end

  def list_children() do
    GenServer.call(__MODULE__, :list_children)
  end

  def stop_child(pid) do
    GenServer.call(__MODULE__, {:stop_child, pid})
  end

  @impl GenServer
  def init(args) do
    state = %{children: args}
    {:ok, state}
  end

  @impl GenServer
  def handle_call({:start_children, num}, _, state) do
    child_info =
      Enum.reduce(1..num, %{}, fn n, acc ->
        child_name = "SimpleQueue" <> Integer.to_string(n)

        if length(Map.keys(state.children)) > 0 do
          state.children
          |> Enum.each(fn {_name, pid} ->
            DynamicSupervisor.terminate_child(SimpleQueue.Supervisor, pid)
          end)
        end

        {:ok, pid} =
          DynamicSupervisor.start_child(SimpleQueue.Supervisor, %{
            id: "SimpleQueue" <> Integer.to_string(n),
            start: {SimpleQueue, :start_link, [String.to_atom(child_name), [n, n + 1, n + 2]]}
          })

        acc = Map.put(acc, child_name, pid)
        acc
      end)

    state = %{state | children: child_info}

    {:reply, state.children, state}
  end

  def handle_call(:list_children, _, state) do
    {:reply, state.children, state}
  end

  def handle_call({:stop_child, name}, _, state) do
    case Map.has_key?(state.children, name) do
      true ->
        pid = state.children[name]
        response = DynamicSupervisor.terminate_child(SimpleQueue.Supervisor, pid)
        state = %{state | children: Map.delete(state.children, name)}
        {:reply, state.children, state}

      false ->
        Logger.error("Child with the name #{name} not found")
        {:reply, {:error, :not_found}, state}
    end
  end
end
