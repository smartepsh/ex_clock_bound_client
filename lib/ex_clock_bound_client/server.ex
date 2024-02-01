defmodule ExClockBoundClient.Server do
  use GenServer

  alias ExClockBoundClient.Context

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl GenServer
  def init(opts) do
    Process.flag(:trap_exit, true)

    case Context.start_socket(opts) do
      {:ok, socket} ->
        state = Keyword.put(opts, :socket, socket)
        {:ok, state}

      _ ->
        {:stop, :clock_bound_socket_error}
    end
  end

  @impl GenServer
  def handle_call(action, from, state) when is_atom(action) do
    handle_call({action, []}, from, state)
  end

  @impl GenServer
  def handle_call({action, params}, _from, state) when is_atom(action) and is_list(params) do
    result = apply(Context, action, params ++ [state])
    {:reply, result, state}
  end

  @impl GenServer
  def terminate(_reason, state), do: Context.clear(state)
end
