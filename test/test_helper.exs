ExUnit.start()

Application.put_env(Prometheus.EctoInstrumenter, Prometheus.EctoInstrumenter.TestRepo,
  [otp_app: Prometheus.EctoInstrumenter,
   loggers: [Ecto.LogEntry,
             Prometheus.EctoInstrumenter],
   adapter: Ecto.Adapters.MySQL,
   pool: Ecto.Adapters.SQL.Sandbox,
   url: "ecto://" <> (System.get_env("MYSQL_URL") || "root@localhost") <> "/ecto_instrumenter_test"])

defmodule Prometheus.EctoInstrumenter.TestRepo do
  use Ecto.Repo, otp_app: Prometheus.EctoInstrumenter
end

defmodule Prometheus.EctoInstrumenter.TestSchema do
  use Ecto.Schema

  import Ecto.Changeset

  schema "test_schema" do
    field :test_field, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(test_field))
    |> validate_required([:test_field])
  end
end

defmodule Prometheus.EctoInstrumenter.Migration do
  use Ecto.Migration

  def change do
    create table(:test_schema) do
      add :test_field, :text
    end
  end
end

Prometheus.EctoInstrumenter.setup()
Application.ensure_all_started(:mariaex)
Mix.Task.run "ecto.create", ~w(-r Prometheus.EctoInstrumenter.TestRepo)
{:ok, _pid} = Prometheus.EctoInstrumenter.TestRepo.start_link
{:ok, _pid} = Ecto.Migration.Supervisor.start_link
Ecto.Migrator.up(Prometheus.EctoInstrumenter.TestRepo, 0, Prometheus.EctoInstrumenter.Migration, log: false)
Ecto.Adapters.SQL.Sandbox.mode(Prometheus.EctoInstrumenter.TestRepo, :manual)
