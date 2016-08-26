defmodule PrometheusEctoTest do
  use ExUnit.Case
  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Prometheus.EctoInstrumenter.TestRepo)
  end

  alias Prometheus.EctoInstrumenter.TestSchema
  alias Prometheus.EctoInstrumenter.TestRepo
  use Prometheus.Metric

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "hello_world" do
    result = TestRepo.query!("SELECT 1")
    assert result.rows == [[1]]
    assert {buckets, sum} = Histogram.value([name: :ecto_query_duration_microseconds,
                                             labels: [:ok]])
    assert sum > 0
    assert 1 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = Histogram.value([name: :ecto_queue_duration_microseconds,
                                             labels: [:ok]])
    assert sum > 0
    assert 1 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = Histogram.value([name: :ecto_db_query_duration_microseconds,
                                             labels: [:ok]])
    assert sum > 0
    assert 1 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = Histogram.value([name: :ecto_decode_duration_microseconds,
                                             labels: [:ok]])
    assert sum > 0
    assert 1 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    changeset = TestSchema.changeset(%TestSchema{}, %{test_field: "qwe"})

    ## transactioned insertion - there should be queries with queue/decode_time=nil
    {:ok, _} = TestRepo.transaction(fn -> TestRepo.insert(changeset) end)

    assert {buckets, sum} = Histogram.value([name: :ecto_query_duration_microseconds,
                                             labels: [:ok]])
    assert sum > 0
    assert 4 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = Histogram.value([name: :ecto_queue_duration_microseconds,
                                             labels: [:ok]])
    assert sum > 0
    assert 2 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = Histogram.value([name: :ecto_db_query_duration_microseconds,
                                             labels: [:ok]])
    assert sum > 0
    assert 4 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = Histogram.value([name: :ecto_decode_duration_microseconds,
                                             labels: [:ok]])
    assert sum > 0
    assert 2 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)
  end
end
