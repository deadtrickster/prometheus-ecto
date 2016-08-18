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

With this configuration scrape will look like this:

```
# TYPE ecto_query_duration_microseconds histogram
# HELP ecto_query_duration_microseconds Ecto query duration in microseconds.
ecto_query_duration_microseconds_bucket{stage="decode",result="ok",le="10"} 0
ecto_query_duration_microseconds_bucket{stage="decode",result="ok",le="100"} 45
ecto_query_duration_microseconds_bucket{stage="decode",result="ok",le="1000"} 86
ecto_query_duration_microseconds_bucket{stage="decode",result="ok",le="10000"} 88
ecto_query_duration_microseconds_bucket{stage="decode",result="ok",le="100000"} 88
ecto_query_duration_microseconds_bucket{stage="decode",result="ok",le="300000"} 88
ecto_query_duration_microseconds_bucket{stage="decode",result="ok",le="500000"} 88
ecto_query_duration_microseconds_bucket{stage="decode",result="ok",le="750000"} 88
ecto_query_duration_microseconds_bucket{stage="decode",result="ok",le="1000000"} 88
ecto_query_duration_microseconds_bucket{stage="decode",result="ok",le="1500000"} 88
ecto_query_duration_microseconds_bucket{stage="decode",result="ok",le="2000000"} 88
ecto_query_duration_microseconds_bucket{stage="decode",result="ok",le="3000000"} 88
ecto_query_duration_microseconds_bucket{stage="decode",result="ok",le="+Inf"} 88
ecto_query_duration_microseconds_count{stage="decode",result="ok"} 88
ecto_query_duration_microseconds_sum{stage="decode",result="ok"} 22071
ecto_query_duration_microseconds_bucket{stage="queue",result="ok",le="10"} 0
ecto_query_duration_microseconds_bucket{stage="queue",result="ok",le="100"} 34
ecto_query_duration_microseconds_bucket{stage="queue",result="ok",le="1000"} 87
ecto_query_duration_microseconds_bucket{stage="queue",result="ok",le="10000"} 88
ecto_query_duration_microseconds_bucket{stage="queue",result="ok",le="100000"} 88
ecto_query_duration_microseconds_bucket{stage="queue",result="ok",le="300000"} 88
ecto_query_duration_microseconds_bucket{stage="queue",result="ok",le="500000"} 88
ecto_query_duration_microseconds_bucket{stage="queue",result="ok",le="750000"} 88
ecto_query_duration_microseconds_bucket{stage="queue",result="ok",le="1000000"} 88
ecto_query_duration_microseconds_bucket{stage="queue",result="ok",le="1500000"} 88
ecto_query_duration_microseconds_bucket{stage="queue",result="ok",le="2000000"} 88
ecto_query_duration_microseconds_bucket{stage="queue",result="ok",le="3000000"} 88
ecto_query_duration_microseconds_bucket{stage="queue",result="ok",le="+Inf"} 88
ecto_query_duration_microseconds_count{stage="queue",result="ok"} 88
ecto_query_duration_microseconds_sum{stage="queue",result="ok"} 16589
ecto_query_duration_microseconds_bucket{stage="query",result="ok",le="10"} 0
ecto_query_duration_microseconds_bucket{stage="query",result="ok",le="100"} 0
ecto_query_duration_microseconds_bucket{stage="query",result="ok",le="1000"} 31
ecto_query_duration_microseconds_bucket{stage="query",result="ok",le="10000"} 88
ecto_query_duration_microseconds_bucket{stage="query",result="ok",le="100000"} 88
ecto_query_duration_microseconds_bucket{stage="query",result="ok",le="300000"} 88
ecto_query_duration_microseconds_bucket{stage="query",result="ok",le="500000"} 88
ecto_query_duration_microseconds_bucket{stage="query",result="ok",le="750000"} 88
ecto_query_duration_microseconds_bucket{stage="query",result="ok",le="1000000"} 88
ecto_query_duration_microseconds_bucket{stage="query",result="ok",le="1500000"} 88
ecto_query_duration_microseconds_bucket{stage="query",result="ok",le="2000000"} 88
ecto_query_duration_microseconds_bucket{stage="query",result="ok",le="3000000"} 88
ecto_query_duration_microseconds_bucket{stage="query",result="ok",le="+Inf"} 88
ecto_query_duration_microseconds_count{stage="query",result="ok"} 88
ecto_query_duration_microseconds_sum{stage="query",result="ok"} 153163
```

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

