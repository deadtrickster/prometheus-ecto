defmodule Ecto.PrometheusCollector do

  alias Ecto.PrometheusCollector.Config

  def setup do
    labels = if Config.stages do
      [:stage] ++ Config.labels
    else
      Config.labels
    end
    :prometheus_histogram.declare([name: :ecto_query_duration_microseconds,
                                   help: "Ecto query duration in microseconds.",
                                   labels: labels,
                                   buckets: Config.query_duration_buckets])
  end

  def log(entry) do
    labels = construct_labels(Config.labels, entry)
    stages = Config.stages
    if stages do
      for stage <- stages do
        value = stage_value(stage, entry)
        :prometheus_histogram.observe(:ecto_query_duration_microseconds, [stage] ++ labels, microseconds_time(value))
      end
    else
      :prometheus_histogram.observe(:ecto_query_duration_microseconds, labels, microseconds_time(total_value(entry)))
    end
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
    entry.queue_time + entry.query_time + entry.decode_time
  end
end
