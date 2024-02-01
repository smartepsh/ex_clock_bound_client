defmodule ExClockBoundClient.Context do
  @moduledoc false
  def start_socket(opts) do
    with {:ok, socket} <-
           :gen_udp.open(0, [
             :binary,
             active: false,
             ifaddr: {:local, opts[:client_socket_path]}
           ]),
         :ok <- :gen_udp.connect(socket, {:local, opts[:clock_bound_socket_path]}, 0) do
      {:ok, socket}
    end
  end

  def clear(opts) do
    socket = opts[:socket]
    if socket, do: :gen_udp.close(socket)
    File.rm(opts[:client_socket_path])
    :ok
  end

  # TODO Whatever the length I set , It always returns the correct data
  defp request(data, length, opts) do
    with :ok <- :gen_udp.send(opts[:socket], data),
         {:ok, {_, _, response}} <-
           :gen_udp.recv(opts[:socket], length, opts[:recv_timeout]) do
      {:ok, response}
    end
  end

  def now(opts) do
    request_data = <<1, 1, 0, 0>>

    with {:ok, <<1, 1, 0, 0, earliest::binary-size(8), latest::binary-size(8)>>} <-
           request(request_data, 20, opts) do
      earliest_datetime =
        earliest |> :binary.decode_unsigned() |> DateTime.from_unix!(:nanosecond)

      latest_datetime = latest |> :binary.decode_unsigned() |> DateTime.from_unix!(:nanosecond)
      {:ok, {earliest_datetime, latest_datetime}}
    else
      {:ok, <<1, 0, _rest::binary>>} -> {:error, :clock_bound_server_error}
      err -> err
    end
  end

  def deviation(opts) do
    request_data = <<1, 1, 0, 0>>

    with {:ok, <<1, 1, 0, 0, earliest::binary-size(8), latest::binary-size(8)>>} <-
           request(request_data, 20, opts) do
      earliest = :binary.decode_unsigned(earliest)
      latest = :binary.decode_unsigned(latest)

      diff = latest - earliest
      round_up_deviation = ceil(diff / 2)

      {:ok, round_up_deviation}
    else
      {:ok, <<1, 0, _rest::binary>>} -> {:error, :clock_bound_server_error}
      err -> err
    end
  end

  def before?(nanosecond, opts) do
    request_data = <<1, 2, 0, 0>> <> :binary.encode_unsigned(nanosecond)

    with {:ok, <<1, 2, 0, 0, result>>} <- request(request_data, 5, opts) do
      {:ok, result == <<1>>}
    else
      {:ok, <<1, 0, _rest::binary>>} -> {:error, :clock_bound_server_error}
      err -> err
    end
  end

  def after?(nanosecond, opts) do
    request_data = <<1, 3, 0, 0>> <> :binary.encode_unsigned(nanosecond)

    with {:ok, <<1, 3, 0, 0, result>>} <- request(request_data, 5, opts) do
      {:ok, result == <<1>>}
    else
      {:ok, <<1, 0, _rest::binary>>} -> {:error, :clock_bound_server_error}
      err -> err
    end
  end
end
