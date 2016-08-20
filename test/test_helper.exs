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

  schema "test_schema" do
    field :test_field, :string
  end
end

Prometheus.EctoInstrumenter.setup()
Application.ensure_all_started(:mariaex)
Mix.Task.run "ecto.create", ~w(-r Prometheus.EctoInstrumenter.TestRepo)
{:ok, _pid} = Prometheus.EctoInstrumenter.TestRepo.start_link
Ecto.Adapters.SQL.Sandbox.mode(Prometheus.EctoInstrumenter.TestRepo, :manual)
