# ExClockBoundClient
![Hex.pm Version](https://img.shields.io/hexpm/v/ex_clock_bound_client)
![Hex.pm License](https://img.shields.io/hexpm/l/ex_clock_bound_client)

This is the elixir version of [aws clock bound client](https://github.com/aws/clock-bound/tree/main/clock-bound-c), to communicate with [this service](https://github.com/aws/clock-bound).

## Preparation

Make sure the service is running correctly.

## Installation

By adding `ex_clock_bound_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_clock_bound_client, "~> 0.0.1"}
  ]
end
```

## Usage

### Runtime Configurations

All configurations are runtime configuration, and have default values.

```elixir
import Config

config :ex_clock_bound_client,
  clock_bound_socket_path: "/run/clockboundd/clockboundd.sock",
  client_socket_path: Path.expand("./client.sock"),
  recv_timeout: 100, # socket recv timeout
  frequency_error: 1 # Setting clock frequency to 1ppm to match chrony
```

### Usage

There are 5 APIs in this library, and additional `deviation/0` are added compared to the [official client](https://github.com/aws/clock-bound/tree/main/clock-bound-c).

- `ExCloudBoundClient.now/0`
- `ExCloudBoundClient.timing/0`
- `ExCloudBoundClient.deviation/0`
- `ExCloudBoundClient.before?/1`
- `ExCloudBoundClient.after?/1`

See [`t:ExClockBoundClient`](https://hexdocs.pm/ex_clock_bound_client/ExClockBoundClient.html) for details.

## Todo

This application is just implement a happy path, all exceptions need to be considered.
