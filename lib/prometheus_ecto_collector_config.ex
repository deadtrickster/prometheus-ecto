defmodule Ecto.PrometheusCollector.Config do

  def stages do
    [:queue, :query, :decode]
  end
  
  def labels do
    [:result]
  end

  def query_duration_buckets do
    [10, 100, 1_000, 10_000, 100_000, 300_000, 500_000, 750_000, 1_000_000, 1_500_000, 2_000_000, 3_000_000]
  end
  
end
