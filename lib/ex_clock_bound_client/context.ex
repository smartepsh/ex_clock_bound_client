defmodule ExClockBoundClient.Context do
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
end
