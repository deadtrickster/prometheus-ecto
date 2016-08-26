defmodule Prometheus.EctoInstrumenter do

  use Prometheus.Config, [stages: [:queue, :query, :decode],
                          labels: [:result],
                          query_duration_buckets: [10, 100, 1_000, 10_000, 100_000, 300_000,
                                                   500_000, 750_000, 1_000_000, 1_500_000,
                                                   2_000_000, 3_000_000],
                          registry: :default]

  use Prometheus.Metric

  ## TODO: support different repos via repo label
  defmacro __using__(_opts) do
    module_name = __CALLER__.module

    labels = Config.labels(module_name)
    nlabels = normalize_labels(labels)
    stages = Config.stages(module_name)
    registry = Config.registry(module_name)
    query_duration_buckets = Config.query_duration_buckets(module_name)

    quote do

      use Prometheus.Metric

      def setup do
        unquote_splicing(
          for stage <- stages do
            quote do
              Histogram.declare([name: unquote(stage_metric_name(stage)),
                                 help: unquote(stage_metric_help(stage)),
                                 labels: unquote(nlabels),
                                 buckets: unquote(query_duration_buckets),
                                 registry: unquote(registry)])
            end
          end)

        Histogram.declare([name: :ecto_query_duration_microseconds,
                           help: "Total Ecto query time",
                           labels: unquote(nlabels),
                           buckets: unquote(query_duration_buckets),
                           registry: unquote(registry)])
      end

      def log(entry) do
        labels = unquote(construct_labels(labels))

        unquote_splicing do
          if stages do
            for stage <- stages do
              quote do
                value = unquote(stage_value(stage))
                if value != nil do
                  Histogram.observe([registry: unquote(registry),
                                     name: unquote(stage_metric_name(stage)),
                                     labels: labels], microseconds_time(value))
                end
              end
            end
          end
        end

        Histogram.observe([registry: unquote(registry),
                           name: :ecto_query_duration_microseconds,
                           labels: labels], total_value(entry))
        entry
      end

      def total_value(entry) do
        zero_if_nil(entry.queue_time) +
        zero_if_nil(entry.query_time) +
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
        System.convert_time_unit(time, :native, :micro_seconds)
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

  defp stage_metric_name(:queue), do: :ecto_queue_duration_microseconds
  defp stage_metric_name(:query), do: :ecto_db_query_duration_microseconds
  defp stage_metric_name(:decode), do: :ecto_decode_duration_microseconds

  defp stage_metric_help(:queue), do: "The time spent to check the connection out in microseconds."
  defp stage_metric_help(:query), do: "The time spent executing the DB query in microseconds."
  defp stage_metric_help(:decode), do: "The time spent decoding the result in microseconds."

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
