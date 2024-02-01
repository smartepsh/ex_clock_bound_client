defmodule ExClockBoundClient do
  alias ExClockBoundClient.Server

  def now do
    GenServer.call(Server, :now)
  end

  def timing do
    GenServer.call(Server, :timing)
  end

  def deviation do
    GenServer.call(Server, :deviation)
  end

  def before?(datetime) do
    with {:ok, datetime} <- normalize_datetime(datetime) do
      GenServer.call(Server, {:before?, [datetime]})
    end
  end

  def after?(datetime) do
    with {:ok, datetime} <- normalize_datetime(datetime) do
      GenServer.call(Server, {:after?, [datetime]})
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
