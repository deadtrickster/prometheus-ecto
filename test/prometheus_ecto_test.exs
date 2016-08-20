defmodule PrometheusEctoTest do
  use ExUnit.Case
  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Prometheus.EctoInstrumenter.TestRepo)
  end
  test "the truth" do
    assert 1 + 1 == 2
  end

  test "hello_world" do
    result = Prometheus.EctoInstrumenter.TestRepo.query!("SELECT 1")
    assert result.rows == [[1]]
    assert {buckets, sum} = :prometheus_histogram.value(:ecto_query_duration_microseconds, [:ok])
    assert sum > 0
    assert 1 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = :prometheus_histogram.value(:ecto_queue_duration_microseconds, [:ok])
    assert sum > 0
    assert 1 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = :prometheus_histogram.value(:ecto_db_query_duration_microseconds, [:ok])
    assert sum > 0
    assert 1 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = :prometheus_histogram.value(:ecto_decode_duration_microseconds, [:ok])
    assert sum > 0
    assert 1 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)
  end

  ### test transactioned insertion - there should be query with queue/decode_time=nil
end
