# PrometheusEcto

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

