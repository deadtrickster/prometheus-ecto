# PrometheusEcto [![Hex.pm](https://img.shields.io/hexpm/v/prometheus_ecto.svg?maxAge=2592000)](https://hex.pm/packages/prometheus_ecto) [![Build Status](https://travis-ci.org/deadtrickster/prometheus-ecto.svg?branch=master)](https://travis-ci.org/deadtrickster/prometheus-ecto)

## Setup

On app/supervisor start:

```elixir
    Prometheus.EctoInstrumenter.setup()
```

In your Repo config:

```elixir
  ...
  loggers: [Ecto.LogEntry, Prometheus.EctoInstrumenter]
  ....
```

## Configuration

This integartion is configured via `EctoInstrumenter` `:prometheus` app env key

Default configuration:

```elixir
config :prometheus, EctoInstrumenter,
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
# TYPE ecto_decode_duration_microseconds histogram
# HELP ecto_decode_duration_microseconds The time spent decoding the result in microseconds.
ecto_decode_duration_microseconds_bucket{result="ok",le="10"} 0
ecto_decode_duration_microseconds_bucket{result="ok",le="100"} 72
ecto_decode_duration_microseconds_bucket{result="ok",le="1000"} 147
ecto_decode_duration_microseconds_bucket{result="ok",le="10000"} 148
ecto_decode_duration_microseconds_bucket{result="ok",le="100000"} 148
ecto_decode_duration_microseconds_bucket{result="ok",le="300000"} 148
ecto_decode_duration_microseconds_bucket{result="ok",le="500000"} 148
ecto_decode_duration_microseconds_bucket{result="ok",le="750000"} 148
ecto_decode_duration_microseconds_bucket{result="ok",le="1000000"} 148
ecto_decode_duration_microseconds_bucket{result="ok",le="1500000"} 148
ecto_decode_duration_microseconds_bucket{result="ok",le="2000000"} 148
ecto_decode_duration_microseconds_bucket{result="ok",le="3000000"} 148
ecto_decode_duration_microseconds_bucket{result="ok",le="+Inf"} 148
ecto_decode_duration_microseconds_count{result="ok"} 148
ecto_decode_duration_microseconds_sum{result="ok"} 26736
# TYPE ecto_query_duration_microseconds histogram
# HELP ecto_query_duration_microseconds Total Ecto query time
ecto_query_duration_microseconds_bucket{result="ok",le="10"} 0
ecto_query_duration_microseconds_bucket{result="ok",le="100"} 0
ecto_query_duration_microseconds_bucket{result="ok",le="1000"} 0
ecto_query_duration_microseconds_bucket{result="ok",le="10000"} 0
ecto_query_duration_microseconds_bucket{result="ok",le="100000"} 0
ecto_query_duration_microseconds_bucket{result="ok",le="300000"} 0
ecto_query_duration_microseconds_bucket{result="ok",le="500000"} 5
ecto_query_duration_microseconds_bucket{result="ok",le="750000"} 16
ecto_query_duration_microseconds_bucket{result="ok",le="1000000"} 25
ecto_query_duration_microseconds_bucket{result="ok",le="1500000"} 55
ecto_query_duration_microseconds_bucket{result="ok",le="2000000"} 77
ecto_query_duration_microseconds_bucket{result="ok",le="3000000"} 111
ecto_query_duration_microseconds_bucket{result="ok",le="+Inf"} 162
ecto_query_duration_microseconds_count{result="ok"} 162
ecto_query_duration_microseconds_sum{result="ok"} 790092483
ecto_query_duration_microseconds_bucket{result="error",le="10"} 0
ecto_query_duration_microseconds_bucket{result="error",le="100"} 0
ecto_query_duration_microseconds_bucket{result="error",le="1000"} 0
ecto_query_duration_microseconds_bucket{result="error",le="10000"} 0
ecto_query_duration_microseconds_bucket{result="error",le="100000"} 0
ecto_query_duration_microseconds_bucket{result="error",le="300000"} 0
ecto_query_duration_microseconds_bucket{result="error",le="500000"} 0
ecto_query_duration_microseconds_bucket{result="error",le="750000"} 0
ecto_query_duration_microseconds_bucket{result="error",le="1000000"} 0
ecto_query_duration_microseconds_bucket{result="error",le="1500000"} 0
ecto_query_duration_microseconds_bucket{result="error",le="2000000"} 1
ecto_query_duration_microseconds_bucket{result="error",le="3000000"} 6
ecto_query_duration_microseconds_bucket{result="error",le="+Inf"} 6
ecto_query_duration_microseconds_count{result="error"} 6
ecto_query_duration_microseconds_sum{result="error"} 14308854
# TYPE ecto_db_query_duration_microseconds histogram
# HELP ecto_db_query_duration_microseconds The time spent executing the DB query in microseconds.
ecto_db_query_duration_microseconds_bucket{result="ok",le="10"} 0
ecto_db_query_duration_microseconds_bucket{result="ok",le="100"} 0
ecto_db_query_duration_microseconds_bucket{result="ok",le="1000"} 53
ecto_db_query_duration_microseconds_bucket{result="ok",le="10000"} 146
ecto_db_query_duration_microseconds_bucket{result="ok",le="100000"} 162
ecto_db_query_duration_microseconds_bucket{result="ok",le="300000"} 162
ecto_db_query_duration_microseconds_bucket{result="ok",le="500000"} 162
ecto_db_query_duration_microseconds_bucket{result="ok",le="750000"} 162
ecto_db_query_duration_microseconds_bucket{result="ok",le="1000000"} 162
ecto_db_query_duration_microseconds_bucket{result="ok",le="1500000"} 162
ecto_db_query_duration_microseconds_bucket{result="ok",le="2000000"} 162
ecto_db_query_duration_microseconds_bucket{result="ok",le="3000000"} 162
ecto_db_query_duration_microseconds_bucket{result="ok",le="+Inf"} 162
ecto_db_query_duration_microseconds_count{result="ok"} 162
ecto_db_query_duration_microseconds_sum{result="ok"} 697637
ecto_db_query_duration_microseconds_bucket{result="error",le="10"} 0
ecto_db_query_duration_microseconds_bucket{result="error",le="100"} 0
ecto_db_query_duration_microseconds_bucket{result="error",le="1000"} 0
ecto_db_query_duration_microseconds_bucket{result="error",le="10000"} 6
ecto_db_query_duration_microseconds_bucket{result="error",le="100000"} 6
ecto_db_query_duration_microseconds_bucket{result="error",le="300000"} 6
ecto_db_query_duration_microseconds_bucket{result="error",le="500000"} 6
ecto_db_query_duration_microseconds_bucket{result="error",le="750000"} 6
ecto_db_query_duration_microseconds_bucket{result="error",le="1000000"} 6
ecto_db_query_duration_microseconds_bucket{result="error",le="1500000"} 6
ecto_db_query_duration_microseconds_bucket{result="error",le="2000000"} 6
ecto_db_query_duration_microseconds_bucket{result="error",le="3000000"} 6
ecto_db_query_duration_microseconds_bucket{result="error",le="+Inf"} 6
ecto_db_query_duration_microseconds_count{result="error"} 6
ecto_db_query_duration_microseconds_sum{result="error"} 14306
# TYPE ecto_queue_duration_microseconds histogram
# HELP ecto_queue_duration_microseconds The time spent to check the connection out in microseconds.
ecto_queue_duration_microseconds_bucket{result="ok",le="10"} 0
ecto_queue_duration_microseconds_bucket{result="ok",le="100"} 34
ecto_queue_duration_microseconds_bucket{result="ok",le="1000"} 143
ecto_queue_duration_microseconds_bucket{result="ok",le="10000"} 154
ecto_queue_duration_microseconds_bucket{result="ok",le="100000"} 154
ecto_queue_duration_microseconds_bucket{result="ok",le="300000"} 154
ecto_queue_duration_microseconds_bucket{result="ok",le="500000"} 154
ecto_queue_duration_microseconds_bucket{result="ok",le="750000"} 154
ecto_queue_duration_microseconds_bucket{result="ok",le="1000000"} 154
ecto_queue_duration_microseconds_bucket{result="ok",le="1500000"} 154
ecto_queue_duration_microseconds_bucket{result="ok",le="2000000"} 154
ecto_queue_duration_microseconds_bucket{result="ok",le="3000000"} 154
ecto_queue_duration_microseconds_bucket{result="ok",le="+Inf"} 154
ecto_queue_duration_microseconds_count{result="ok"} 154
ecto_queue_duration_microseconds_sum{result="ok"} 65503
```

## Installation

[Available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `prometheus_ecto` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:prometheus_ecto, "~> 0.0.4"}]
    end
    ```

  2. Ensure `prometheus_ecto` is started before your application:

    ```elixir
    def application do
      [applications: [:prometheus_ecto]]
    end
    ```

