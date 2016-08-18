# PrometheusEcto

## Setup

On app/supervisor start:

```elixir
    Ecto.PrometheusCollector.setup()
```

In your Repo config:

```elixir
  ...
  loggers: [Ecto.LogEntry, Ecto.PrometheusCollector]
  ....
```

## Configuration

This integartion is configured via `EctoCollector` `:prometheus` app env key

Default configuration:

```elixir
config :prometheus, EctoCollector,
  labels: [:result],
  stages: [:queue, :query, :decode],
  query_duration_buckets: [10, 100, 1_000, 10_000, 100_000, 300_000,
                            500_000, 750_000, 1_000_000, 1_500_000,
                            2_000_000, 3_000_000]
``` 

Duration units are **microseconds**. 
You can find more on what stages are available and their description [here](https://hexdocs.pm/ecto/Ecto.LogEntry.html).

## Installation

[Available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `prometheus_ecto` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:prometheus_ecto, "~> 0.1.0"}]
    end
    ```

  2. Ensure `prometheus_ecto` is started before your application:

    ```elixir
    def application do
      [applications: [:prometheus_ecto]]
    end
    ```

