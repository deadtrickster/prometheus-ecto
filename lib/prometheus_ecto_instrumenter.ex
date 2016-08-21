defmodule Prometheus.EctoInstrumenter do

  use Prometheus.Config, [stages: [:queue, :query, :decode],
                          labels: [:result],
                          query_duration_buckets: [10, 100, 1_000, 10_000, 100_000, 300_000,
                                                   500_000, 750_000, 1_000_000, 1_500_000,
                                                   2_000_000, 3_000_000],
                          registry: :default]

  def setup do
    labels = Config.labels
    stages = Config.stages
    for stage <- stages do
      :prometheus_histogram.declare([name: stage_metric_name(stage),
                                     help: stage_metric_help(stage),
                                     labels: labels,
                                     buckets: Config.query_duration_buckets], Config.registry)
    end

    :prometheus_histogram.declare([name: :ecto_query_duration_microseconds,
                                   help: "Total Ecto query time",
                                   labels: labels,
                                   buckets: Config.query_duration_buckets], Config.registry)
  end

  def log(entry) do
    labels = construct_labels(Config.labels, entry)
    stages = Config.stages
    if stages do
      for stage <- stages do
        value = stage_value(stage, entry)
        if value != nil do
          :prometheus_histogram.observe(Config.registry, stage_metric_name(stage), labels, microseconds_time(value))
        end
      end
    end
    :prometheus_histogram.observe(Config.registry, :ecto_query_duration_microseconds, labels, total_value(entry))
    entry
  end

  defp construct_labels(labels, entry) do
    for label <- labels, do: label_value(label, entry)
  end

  defp microseconds_time(time) do
    System.convert_time_unit(time, :native, :micro_seconds)
  end

  defp label_value(:result, entry) do
    {result, _} = entry.result
    result
  end
  defp label_value({label, fun}, entry) when is_function(fun, 2), do: fun.(label, entry)
  defp label_value(fun, entry) when is_function(fun, 1), do: fun.(entry)

  defp stage_metric_name(:queue), do: :ecto_queue_duration_microseconds
  defp stage_metric_name(:query), do: :ecto_db_query_duration_microseconds
  defp stage_metric_name(:decode), do: :ecto_decode_duration_microseconds

  defp stage_metric_help(:queue), do: "The time spent to check the connection out in microseconds."
  defp stage_metric_help(:query), do: "The time spent executing the DB query in microseconds."
  defp stage_metric_help(:decode), do: "The time spent decoding the result in microseconds."

  defp stage_value(:queue, entry) do
    entry.queue_time
  end
  defp stage_value(:query, entry) do
    entry.query_time
  end
  defp stage_value(:decode, entry) do
    entry.decode_time
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
end
