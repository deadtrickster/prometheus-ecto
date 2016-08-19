defmodule Prometheus.EctoInstrumenter.Config do

  @default_stages [:queue, :query, :decode]
  @default_labels [:result]
  @default_query_duration_buckets [10, 100, 1_000, 10_000, 100_000, 300_000,
                                   500_000, 750_000, 1_000_000, 1_500_000,
                                   2_000_000, 3_000_000]
  @default_config [stages: @default_stages,
                   labels: @default_labels,
                   query_duration_buckets: @default_query_duration_buckets]

  def stages do
    config(:stages, @default_stages)
  end

  def labels do
    config(:labels, @default_labels)
  end

  def query_duration_buckets do
    config(:query_duration_buckets, @default_query_duration_buckets)
  end

  def collector_config do
    Application.get_env(:prometheus, EctoInstrumenter, @default_config)
  end

  def config(name, default) do
    collector_config
    |> Keyword.get(name, default)
  end
end
