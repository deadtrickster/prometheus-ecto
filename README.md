# PrometheusEcto [![Hex.pm](https://img.shields.io/hexpm/v/prometheus_ecto.svg?maxAge=2592000)](https://hex.pm/packages/prometheus_ecto) [![Build Status](https://travis-ci.org/deadtrickster/prometheus-ecto.svg?branch=master)](https://travis-ci.org/deadtrickster/prometheus-ecto)

Ecto integration for [Prometheus.erl](https://github.com/deadtrickster/prometheus.erl)

## Documentation

Please find documentation on [hexdocs](https://hexdocs.pm/prometheus_ecto/index.html).

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

