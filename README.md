# Prometheus.io Ecto Instrumenter
[![Hex.pm](https://img.shields.io/hexpm/v/prometheus_ecto.svg?maxAge=2592000)](https://hex.pm/packages/prometheus_ecto)
[![Hex.pm](https://img.shields.io/hexpm/dt/prometheus_ecto.svg?maxAge=2592000)](https://hex.pm/packages/prometheus_ecto)
[![Build Status](https://travis-ci.org/deadtrickster/prometheus-ecto.svg?branch=master)](https://travis-ci.org/deadtrickster/prometheus-ecto)
[![Documentation](https://img.shields.io/badge/documentation-on%20hexdocs-green.svg)](https://hexdocs.pm/prometheus_ecto/)

Ecto integration for [Prometheus.ex](https://github.com/deadtrickster/prometheus.ex)

 - IRC: #elixir-lang on Freenode;
 - [Slack](https://elixir-slackin.herokuapp.com/): #prometheus channel - [Browser](https://elixir-lang.slack.com/messages/prometheus) or App(slack://elixir-lang.slack.com/messages/prometheus).

## Quickstart

1. Define your instrumenter:

    ```elixir
    defmodule MyApp.Repo.Instrumenter do
      use Prometheus.EctoInstrumenter
    end
    ```

2. Call `MyApp.Repo.Instrumenter.setup/0` when application starts (e.g. supervisor setup):

    ```elixir
    MyApp.Repo.Instrumenter.setup()
    ```

3. If using Ecto 2, add `MyApp.Repo.Instrumenter` to Repo loggers list:
    ```elixir
    config :myapp, MyApp.Repo,
      loggers: [MyApp.Repo.Instrumenter, Ecto.LogEntry]
      # ...
    ```
    If using Ecto 3, attach to telemetry in your application start function:

    ```elixir
    :ok =
      Telemetry.attach(
        "prometheus-ecto",
        [:my_app, :repo, :query],
        MyApp.Repo.Instrumenter,
        :handle_event,
        %{}
      )
    ```
    If using Ecto 3.1 with telemetry 0.4+:

    ```elixir
    :ok =
      :telemetry.attach(
        "prometheus-ecto",
        [:my_app, :repo, :query],
        &MyApp.Repo.Instrumenter.handle_event/4,        
        %{}
      )
    ```

## Integrations / Collectors / Instrumenters
 - [Ecto collector](https://github.com/deadtrickster/prometheus-ecto)
 - [Plugs Instrumenter/Exporter](https://github.com/deadtrickster/prometheus-plugs)
 - [Elli middleware](https://github.com/elli-lib/elli_prometheus)
 - [Fuse plugin](https://github.com/jlouis/fuse#fuse_stats_prometheus)
 - [Phoenix instrumenter](https://github.com/deadtrickster/prometheus-phoenix)
 - [Process Info Collector](https://github.com/deadtrickster/prometheus_process_collector.erl)
 - [RabbitMQ Exporter](https://github.com/deadtrickster/prometheus_rabbitmq_exporter)

## Installation

[Available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `prometheus_ecto` to your list of dependencies in `mix.exs`:

      ```elixir
      def deps do
        [{:prometheus_ecto, "~> 1.4.1"}]
      end
      ```

  2. Ensure `prometheus_ecto` is started before your application:

      ```elixir
      def application do
        [applications: [:prometheus_ecto]]
      end
      ```
