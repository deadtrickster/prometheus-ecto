ExUnit.start()

Application.put_env(
  Prometheus.EctoInstrumenter,
  Prometheus.EctoInstrumenter.TestRepo,
  otp_app: Prometheus.EctoInstrumenter,
  pool: Ecto.Adapters.SQL.Sandbox,
  url: "ecto://" <> (System.get_env("MYSQL_URL") || "root@localhost") <> "/ecto_instrumenter_test"
)

Application.put_env(
  :prometheus,
  TestEctoInstrumenterWithConfig,
  labels: [:custom_label],
  registry: :qwe,
  stages: [:queue, :query],
  counter: true,
  query_duration_buckets: [100, 200],
  duration_unit: :seconds
)

defmodule TestEctoInstrumenter do
  use Prometheus.EctoInstrumenter
end

defmodule TestEctoInstrumenterWithConfig do
  use Prometheus.EctoInstrumenter

  def label_value(:custom_label, _) do
    "custom_label"
  end
end

defmodule Prometheus.EctoInstrumenter.TestRepo do
  use Ecto.Repo, adapter: Ecto.Adapters.MyXQL, otp_app: Prometheus.EctoInstrumenter
end

defmodule Prometheus.EctoInstrumenter.TestSchema do
  use Ecto.Schema

  import Ecto.Changeset

  schema "test_schema" do
    field(:test_field, :string)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(test_field)a)
    |> validate_required([:test_field])
  end
end

defmodule Prometheus.EctoInstrumenter.Migration do
  use Ecto.Migration

  def change do
    create table(:test_schema) do
      add(:test_field, :text)
    end
  end
end

Mix.Task.run("ecto.create", ~w(-r Prometheus.EctoInstrumenter.TestRepo))
Application.ensure_all_started(:ecto)
{:ok, _pid} = Prometheus.EctoInstrumenter.TestRepo.start_link()

Ecto.Migrator.up(
  Prometheus.EctoInstrumenter.TestRepo,
  0,
  Prometheus.EctoInstrumenter.Migration,
  log: false
)

Ecto.Adapters.SQL.Sandbox.mode(Prometheus.EctoInstrumenter.TestRepo, :manual)
