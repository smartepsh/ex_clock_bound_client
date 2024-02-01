defmodule ExClockBoundClient do
  @moduledoc """
    The elixir version of aws clock bound client.
  """

  alias ExClockBoundClient.Server

  @type nanosecond :: non_neg_integer
  @type unix_time_with_unit ::
          {nanosecond, :second | :millisecond | :microsecond | :nanosecond}

  @doc """
  Returns the bounds of the current system time +/- the error calculated from chrony.

  ## Examples

      iex> ExClockBoundClient.now()
      {:ok, {~U[2024-02-01 11:14:57.656524Z], ~U[2024-02-01 11:14:57.706487Z]}}

  """
  @spec now() ::
          {:ok, {earliest_datetime :: DateTime.t(), latest_datetime :: DateTime.t()}}
          | {:error, term}
  def now do
    GenServer.call(Server, :now)
  end

  @doc """
  Execute `function` and return bounds on execution time.

  ## Examples

      iex> ExClockBoundClient.timing(fn -> :timer.sleep(1000) end)
      {:ok, {{~U[2024-02-01 11:14:57.656524Z], ~U[2024-02-01 11:14:57.706487Z]}, {1011, 1033}}}
  """
  @spec timing(function()) ::
          {:ok,
           {{earliest_start :: DateTime.t(), latest_finish :: DateTime.t()},
            {min_execution_time :: non_neg_integer, max_execution_time :: non_neg_integer}}}
          | {:error, term}
  def timing(func) do
    GenServer.call(Server, {:timing, func})
  end

  @doc """
  Returns the deviation in nanosecond of the current system time from the chrony server.

  ## Examples

      iex> ExClockBoundClient.deviation()
      {:ok, 1314}
  """
  @spec deviation() :: {:ok, nanosecond()} | {:error, term}
  def deviation do
    GenServer.call(Server, :deviation)
  end

  @doc """
  Returns true if the provided timestamp is before the earliest error bound. Otherwise, returns false.

  ## DateTime Format

  See `DateTime Format` in `after?/1` .

  ## Examples

      iex> ExClockBoundClient.before?(~U[2024-02-01 11:14:57.656524Z])
      {:ok, true}
  """
  @spec before?(DateTime.t() | unix_time_with_unit()) :: {:ok, boolean} | {:error, term}
  def before?(datetime) do
    with {:ok, datetime} <- normalize_datetime(datetime) do
      GenServer.call(Server, {:before?, datetime})
    end
  end

  @doc """
  Returns true if the provided timestamp is after the latest error bound. Otherwise, returns false.

  ## DateTime Format

  The `datetime` argument could be one of :
  - a DateTime struct.
  - a tuple of the form `{unix_time, unit}`. `unix_time` is an integer in unit, and `unit` is one of `:second`, `:millisecond`, `:microsecond`, or `:nanosecond`.

  ## Examples

      iex> ExClockBoundClient.before?(~U[2024-02-01 11:14:57.656524Z])
      {:ok, true}
  """
  @spec after?(DateTime.t() | unix_time_with_unit()) :: {:ok, boolean} | {:error, term}
  def after?(datetime) do
    with {:ok, datetime} <- normalize_datetime(datetime) do
      GenServer.call(Server, {:after?, datetime})
    end
  end

  defp normalize_datetime(datetime) do
    with {:ok, unix_nanosecond} <- do_normalize_datetime(datetime),
         {:ok, _datetime} <- DateTime.from_unix(unix_nanosecond, :nanosecond) do
      {:ok, unix_nanosecond}
    else
      _ -> {:error, :invliad_datetime}
    end
  end

  defp do_normalize_datetime(%DateTime{} = datetime),
    do: {:ok, DateTime.to_unix(datetime, :nanosecond)}

  defp do_normalize_datetime(unix_time) when is_integer(unix_time),
    do: do_normalize_datetime({unix_time, :second})

  defp do_normalize_datetime({unix_time, :second}) when is_integer(unix_time) do
    {:ok, unix_time * 1_000_000_000}
  end

  defp do_normalize_datetime({unix_time, :millisecond}) when is_integer(unix_time) do
    {:ok, unix_time * 1_000_000}
  end

  defp do_normalize_datetime({unix_time, :microsecond}) when is_integer(unix_time) do
    {:ok, unix_time * 1_000}
  end

  defp do_normalize_datetime({unix_time, :nanosecond}) when is_integer(unix_time),
    do: {:ok, unix_time}

  defp do_normalize_datetime(_), do: {:error, :invalid_datetime}

  @doc false
  def config do
    config = Application.get_all_env(:ex_clock_bound_client)
    Keyword.merge(default_config(), config)
  end

  defp default_config do
    [
      clock_bound_socket_path: "/run/clockboundd/clockboundd.sock",
      client_socket_path: Path.expand("./client.sock"),
      recv_timeout: 100,
      # 1 ppm for chrony
      frequency_error: 1
    ]
  end
end
