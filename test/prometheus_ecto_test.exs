defmodule PrometheusEctoTest do
  use ExUnit.Case

  require Prometheus.Registry

  alias Prometheus.EctoInstrumenter.TestRepo
  alias Prometheus.EctoInstrumenter.TestSchema

  setup do
    Prometheus.Registry.clear(:default)
    Prometheus.Registry.clear(:qwe)
    TestEctoInstrumenter.setup()
    TestEctoInstrumenterWithConfig.setup()
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TestRepo)
  end

  use Prometheus.Metric

  describe "handle_event/4" do
    test "Defaults decode_time, query_time, queue_time to 0 when not present" do
      metadata =
        TestEctoInstrumenter.append_latency_to_metadata(
          %{total_time: 2_443_000},
          %{
            params: [],
            query: "",
            repo: TestRepo,
            result: {:ok, %{}},
            source: nil,
            type: :ecto_sql_query
          }
        )

      assert metadata.decode_time == 0
      assert metadata.query_time == 0
      assert metadata.queue_time == 0
      assert metadata.total_time == 2_443_000
    end

    test "Defaults decode_time, query_time and queue_time to 0 when they are nil" do
      metadata =
        TestEctoInstrumenter.append_latency_to_metadata(
          %{queue_time: nil, query_time: nil, decode_time: nil, total_time: 0},
          %{
            params: [],
            query: "",
            repo: TestRepo,
            result: {:ok, %{}},
            source: nil,
            type: :ecto_sql_query
          }
        )

      assert metadata.decode_time == 0
      assert metadata.query_time == 0
      assert metadata.queue_time == 0
      assert metadata.total_time == 0
    end
  end

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "Default test" do
    result = TestRepo.query!("SELECT 1")
    assert result.rows == [[1]]

    assert_raise Prometheus.UnknownMetricError, fn ->
      Counter.value(name: :ecto_queries_total)
    end

    assert {buckets, sum} =
             Histogram.value(
               name: :ecto_query_duration_microseconds,
               labels: [:ok]
             )

    assert sum > 0.1
    assert 1 = Enum.reduce(buckets, fn x, acc -> x + acc end)

    assert {buckets, sum} =
             Histogram.value(
               name: :ecto_queue_duration_microseconds,
               labels: [:ok]
             )

    assert sum > 0
    assert 1 = Enum.reduce(buckets, fn x, acc -> x + acc end)

    assert {buckets, sum} =
             Histogram.value(
               name: :ecto_db_query_duration_microseconds,
               labels: [:ok]
             )

    assert sum > 0.1
    assert 1 = Enum.reduce(buckets, fn x, acc -> x + acc end)

    assert {buckets, sum} =
             Histogram.value(
               name: :ecto_decode_duration_microseconds,
               labels: [:ok]
             )

    assert sum > 0
    assert 1 = Enum.reduce(buckets, fn x, acc -> x + acc end)

    changeset = TestSchema.changeset(%TestSchema{}, %{test_field: "qwe"})

    ## transactioned insertion - there should be queries with queue/decode_time=nil
    {:ok, _} = TestRepo.transaction(fn -> TestRepo.insert(changeset) end)

    assert {buckets, sum} =
             Histogram.value(
               name: :ecto_query_duration_microseconds,
               labels: [:ok]
             )

    assert sum > 0.1
    assert 4 = Enum.reduce(buckets, fn x, acc -> x + acc end)

    assert {buckets, sum} =
             Histogram.value(
               name: :ecto_queue_duration_microseconds,
               labels: [:ok]
             )

    assert sum > 0
    assert 2 = Enum.reduce(buckets, fn x, acc -> x + acc end)

    assert {buckets, sum} =
             Histogram.value(
               name: :ecto_db_query_duration_microseconds,
               labels: [:ok]
             )

    assert sum > 0.1
    assert 4 = Enum.reduce(buckets, fn x, acc -> x + acc end)

    assert {buckets, sum} =
             Histogram.value(
               name: :ecto_decode_duration_microseconds,
               labels: [:ok]
             )

    assert sum > 0
    assert 2 = Enum.reduce(buckets, fn x, acc -> x + acc end)
  end

  test "Custom config test" do
    result = TestRepo.query!("SELECT 1")
    assert result.rows == [[1]]

    assert {buckets, sum} =
             Histogram.value(
               name: :ecto_query_duration_seconds,
               registry: :qwe,
               labels: ["custom_label"]
             )

    assert 3 = length(buckets)
    assert sum < 1
    assert 1 = Enum.reduce(buckets, fn x, acc -> x + acc end)

    assert 1 ==
             Counter.value(
               name: :ecto_queries_total,
               registry: :qwe,
               labels: ["custom_label"]
             )

    assert {buckets, sum} =
             Histogram.value(
               name: :ecto_queue_duration_seconds,
               registry: :qwe,
               labels: ["custom_label"]
             )

    assert 3 = length(buckets)
    assert sum < 1
    assert 1 = Enum.reduce(buckets, fn x, acc -> x + acc end)

    assert {buckets, sum} =
             Histogram.value(
               name: :ecto_db_query_duration_seconds,
               registry: :qwe,
               labels: ["custom_label"]
             )

    assert 3 = length(buckets)
    assert sum < 1
    assert 1 = Enum.reduce(buckets, fn x, acc -> x + acc end)

    assert_raise Prometheus.UnknownMetricError, fn ->
      Histogram.value(
        name: :ecto_decode_duration_seconds,
        registry: :qwe,
        labels: ["custom_label"]
      )
    end

    changeset = TestSchema.changeset(%TestSchema{}, %{test_field: "qwe"})

    ## transactioned insertion - there should be queries with queue/decode_time=nil
    {:ok, _} = TestRepo.transaction(fn -> TestRepo.insert(changeset) end)

    assert {buckets, sum} =
             Histogram.value(
               name: :ecto_query_duration_seconds,
               registry: :qwe,
               labels: ["custom_label"]
             )

    assert 3 = length(buckets)
    assert sum < 1
    assert 4 = Enum.reduce(buckets, fn x, acc -> x + acc end)

    assert {buckets, sum} =
             Histogram.value(
               name: :ecto_queue_duration_seconds,
               registry: :qwe,
               labels: ["custom_label"]
             )

    assert 3 = length(buckets)
    assert sum < 1
    assert 2 = Enum.reduce(buckets, fn x, acc -> x + acc end)

    assert {buckets, sum} =
             Histogram.value(
               name: :ecto_db_query_duration_seconds,
               registry: :qwe,
               labels: ["custom_label"]
             )

    assert 3 = length(buckets)
    assert sum < 1
    assert 4 = Enum.reduce(buckets, fn x, acc -> x + acc end)

    assert_raise Prometheus.UnknownMetricError, fn ->
      Histogram.value(
        name: :ecto_decode_duration_seconds,
        registry: :qwe,
        labels: ["custom_label"]
      )
    end
  end
end
