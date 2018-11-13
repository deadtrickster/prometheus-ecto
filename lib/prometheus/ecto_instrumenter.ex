defmodule Prometheus.EctoInstrumenter do
  @moduledoc """
  Ecto instrumenter generator for Prometheus. Implemented as Ecto logger.

  ### Usage

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

  3. Add `MyApp.Repo.Instrumenter` to Repo loggers list:

  ```elixir
  config :myapp, MyApp.Repo,
    ...
    loggers: [MyApp.Repo.Instrumenter, Ecto.LogEntry]
    ...
  ```

  ### Metrics

  Each Ecto query has different stages. Currently there are three of them:

   - queue - when socket checked out from the pool;
   - query (this instrumenter uses db_query name) - when actual database query performed;
   - decode - when query result decoded.

  Any of these stages can be nil (i.e. not performed). For example queries inside transaction won't have queue
  stage or query can be cashed, etc.

  You can instrument these stages separately
   - queue - `ecto_queue_duration_<duration_unit>`
   - query - `ecto_db_query_duration_<duration_unit>`
   - decode - `ecto_decode_duration_<duration_unit>`.

  Stages can be disabled/enabled via configuration. By default all stages are enabled.

  There is also `ecto_query_duration_<duration_unit>` metric that observers total query execution time.
  Basically it sums non-nil stages.

  There's an ability to count total amount of Ecto queries. It is disabled by default, to enable set 
  `counter: true` in configuration for your instrumenter module then you can instrument it via `ecto_queries_total`.

  Default labels:
   - `:result`

  ### Configuration

  Instrumenter configured via `:prometheus` application environment `MyApp.Repo.Instrumenter` key
  (i.e. app env key is the name of the instrumenter).

  Default configuration:

  ```elixir
  config :prometheus, MyApp.Repo.Instrumenter,
    stages: [:queue, :query, :decode],
    counter: false,
    labels: [:result],
    query_duration_buckets: [10, 100, 1_000, 10_000, 100_000, 300_000,
                             500_000, 750_000, 1_000_000, 1_500_000,
                             2_000_000, 3_000_000],
    registry: :default,
    duration_unit: :microseconds

  ```

  Available duration units:
   - microseconds;
   - milliseconds;
   - seconds;
   - minutes;
   - hours;
   - days.

  Bear in mind that buckets are ***<duration_unit>*** so if you are not using default unit
  you also have to override buckets.

  ### Custom Labels

  Custom labels can be defined by implementing label_value/2 function in instrumenter directly or
  by calling exported function from other module.

  ```elixir
    labels: [:result,
             :my_private_label,
             {:label_from_other_module, Module}, # eqv to {Module, label_value}
             {:non_default_label_value, {Module, custom_fun}}]


  defmodule MyApp.Repo.Instrumenter do
    use Prometheus.EctoInstrumenter

    label_value(:my_private_label, log_entry) do
      ...
    end
  end
  ```
  """

  use Prometheus.Config,
    stages: [:queue, :query, :decode],
    counter: false,
    labels: [:result],
    query_duration_buckets: [
      10,
      100,
      1_000,
      10_000,
      100_000,
      300_000,
      500_000,
      750_000,
      1_000_000,
      1_500_000,
      2_000_000,
      3_000_000
    ],
    registry: :default,
    duration_unit: :microseconds

  use Prometheus.Metric

  ## TODO: support different repos via repo label
  defmacro __using__(_opts) do
    module_name = __CALLER__.module

    labels = Config.labels(module_name)
    nlabels = normalize_labels(labels)
    stages = Config.stages(module_name)
    counter = Config.counter(module_name)
    registry = Config.registry(module_name)
    query_duration_buckets = Config.query_duration_buckets(module_name)
    duration_unit = Config.duration_unit(module_name)

    quote do
      use Prometheus.Metric

      def setup do
        unquote_splicing(
          for stage <- stages do
            quote do
              Histogram.declare(
                name: unquote(stage_metric_name(stage, duration_unit)),
                help: unquote(stage_metric_help(stage, duration_unit)),
                labels: unquote(nlabels),
                buckets: unquote(query_duration_buckets),
                registry: unquote(registry)
              )
            end
          end
        )

        Histogram.declare(
          name: unquote(:"ecto_query_duration_#{duration_unit}"),
          help: unquote("Total Ecto query time in #{duration_unit}."),
          labels: unquote(nlabels),
          buckets: unquote(query_duration_buckets),
          registry: unquote(registry)
        )

        if unquote(counter) do
          Counter.declare(
            name: :ecto_queries_total,
            help:  "Total number of Ecto queries made.",
            labels: unquote(nlabels),
            registry: unquote(registry)
          )
        end
      end

      def handle_event(_event, _latency, metadata, _config) do
        log(metadata)
      end

      def log(entry) do
        labels = unquote(construct_labels(labels))

        unquote_splicing do
          if stages do
            for stage <- stages do
              quote do
                value = unquote(stage_value(stage))

                if value != nil do
                  Histogram.observe(
                    [
                      registry: unquote(registry),
                      name: unquote(stage_metric_name(stage, duration_unit)),
                      labels: labels
                    ],
                    microseconds_time(value)
                  )
                end
              end
            end
          end
        end

        Histogram.observe(
          [
            registry: unquote(registry),
            name: unquote(:"ecto_query_duration_#{duration_unit}"),
            labels: labels
          ],
          total_value(entry)
        )

        if unquote(counter) do
          Counter.inc(
            registry: unquote(registry),
            name: :ecto_queries_total,
            labels: labels
          )
        end

        entry
      end

      def total_value(entry) do
        zero_if_nil(entry.queue_time) + zero_if_nil(entry.query_time) +
          zero_if_nil(entry.decode_time)
      end

      defp zero_if_nil(value) do
        if value == nil do
          0
        else
          value
        end
      end

      defp microseconds_time(time) do
        System.convert_time_unit(time, :native, :microseconds)
      end
    end
  end

  defp normalize_labels(labels) do
    for label <- labels do
      case label do
        {name, _} -> name
        name -> name
      end
    end
  end

  defp stage_metric_name(:queue, duration_unit), do: :"ecto_queue_duration_#{duration_unit}"
  defp stage_metric_name(:query, duration_unit), do: :"ecto_db_query_duration_#{duration_unit}"
  defp stage_metric_name(:decode, duration_unit), do: :"ecto_decode_duration_#{duration_unit}"

  defp stage_metric_help(:queue, duration_unit),
    do: "The time spent to check the connection out in #{duration_unit}."

  defp stage_metric_help(:query, duration_unit),
    do: "The time spent executing the DB query in #{duration_unit}."

  defp stage_metric_help(:decode, duration_unit),
    do: "The time spent decoding the result in #{duration_unit}."

  defp construct_labels(labels) do
    for label <- labels, do: label_value(label)
  end

  defp label_value(:result) do
    quote do
      {result, _} = entry.result
      result
    end
  end

  defp label_value({label, {module, fun}}) do
    quote do
      unquote(module).unquote(fun)(unquote(label), entry)
    end
  end

  defp label_value({label, module}) do
    quote do
      unquote(module).label_value(unquote(label), entry)
    end
  end

  defp label_value(label) do
    quote do
      label_value(unquote(label), entry)
    end
  end

  defp stage_value(:queue) do
    quote do
      entry.queue_time
    end
  end

  defp stage_value(:query) do
    quote do
      entry.query_time
    end
  end

  defp stage_value(:decode) do
    quote do
      entry.decode_time
    end
  end
end
