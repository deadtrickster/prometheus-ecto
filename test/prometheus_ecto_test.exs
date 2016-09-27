defmodule PrometheusEctoTest do
  use ExUnit.Case

  require Prometheus.Registry

  setup do
    Prometheus.Registry.clear(:default)
    Prometheus.Registry.clear(:qwe)
    TestEctoInstrumenter.setup()
    TestEctoInstrumenterWithConfig.setup()
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Prometheus.EctoInstrumenter.TestRepo)
  end

  alias Prometheus.EctoInstrumenter.TestSchema
  alias Prometheus.EctoInstrumenter.TestRepo
  use Prometheus.Metric


  test "the truth" do
    assert 1 + 1 == 2
  end

  test "Default test" do
    result = TestRepo.query!("SELECT 1")
    assert result.rows == [[1]]
    assert {buckets, sum} = Histogram.value([name: :ecto_query_duration_microseconds,
                                             labels: [:ok]])
    assert sum > 0.1
    assert 1 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = Histogram.value([name: :ecto_queue_duration_microseconds,
                                             labels: [:ok]])
    assert sum > 0
    assert 1 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = Histogram.value([name: :ecto_db_query_duration_microseconds,
                                             labels: [:ok]])
    assert sum > 0.1
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
    assert sum > 0.1
    assert 4 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = Histogram.value([name: :ecto_queue_duration_microseconds,
                                             labels: [:ok]])
    assert sum > 0
    assert 2 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = Histogram.value([name: :ecto_db_query_duration_microseconds,
                                             labels: [:ok]])
    assert sum > 0.1
    assert 4 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = Histogram.value([name: :ecto_decode_duration_microseconds,
                                             labels: [:ok]])
    assert sum > 0
    assert 2 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)
  end

  test "Custom config test" do

    result = TestRepo.query!("SELECT 1")
    assert result.rows == [[1]]
    assert {buckets, sum} = Histogram.value([name: :ecto_query_duration_seconds,
                                             registry: :qwe,
                                             labels: ["custom_label"]])
    assert 3 = length(buckets)
    assert sum < 1
    assert 1 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = Histogram.value([name: :ecto_queue_duration_seconds,
                                             registry: :qwe,
                                             labels: ["custom_label"]])
    assert 3 = length(buckets)
    assert sum < 1
    assert 1 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = Histogram.value([name: :ecto_db_query_duration_seconds,
                                             registry: :qwe,
                                             labels: ["custom_label"]])
    assert 3 = length(buckets)
    assert sum < 1
    assert 1 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert_raise Prometheus.UnknownMetricError, fn ->
      Histogram.value([name: :ecto_decode_duration_seconds,
                       registry: :qwe,
                       labels: ["custom_label"]])
    end

    changeset = TestSchema.changeset(%TestSchema{}, %{test_field: "qwe"})

    ## transactioned insertion - there should be queries with queue/decode_time=nil
    {:ok, _} = TestRepo.transaction(fn -> TestRepo.insert(changeset) end)

    assert {buckets, sum} = Histogram.value([name: :ecto_query_duration_seconds,
                                             registry: :qwe,
                                             labels: ["custom_label"]])
    assert 3 = length(buckets)
    assert sum < 1
    assert 4 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = Histogram.value([name: :ecto_queue_duration_seconds,
                                             registry: :qwe,
                                             labels: ["custom_label"]])
    assert 3 = length(buckets)
    assert sum < 1
    assert 2 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert {buckets, sum} = Histogram.value([name: :ecto_db_query_duration_seconds,
                                             registry: :qwe,
                                             labels: ["custom_label"]])
    assert 3 = length(buckets)
    assert sum < 1
    assert 4 = Enum.reduce(buckets, fn(x, acc) -> x + acc end)

    assert_raise Prometheus.UnknownMetricError, fn ->
      Histogram.value([name: :ecto_decode_duration_seconds,
                       registry: :qwe,
                       labels: ["custom_label"]])
    end
  end
end
