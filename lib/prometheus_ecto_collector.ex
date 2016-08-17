defmodule Ecto.PrometheusCollector do

  def setup do
    request_duration_bounds = [10, 100, 1_000, 10_000, 100_000, 300_000, 500_000, 750_000, 1_000_000, 1_500_000, 2_000_000, 3_000_000]
    labels = [:stage, :result]
    :prometheus_histogram.declare([name: :ecto_query_duration_microseconds,
                                   help: "Ecto query duration in microseconds.",
                                   labels: labels,
                                   buckets: request_duration_bounds])
  end

  def log(entry) do
    {result, _} = entry.result
    :prometheus_histogram.observe(:ecto_query_duration_microseconds, [:queue, result], microseconds_time(entry.queue_time))
    :prometheus_histogram.observe(:ecto_query_duration_microseconds, [:query, result], microseconds_time(entry.query_time))
    :prometheus_histogram.observe(:ecto_query_duration_microseconds, [:decode, result], microseconds_time(entry.decode_time))
    entry
  end

  defp microseconds_time(time) do
    :erlang.convert_time_unit(time, :native, :micro_seconds)
  end
end
