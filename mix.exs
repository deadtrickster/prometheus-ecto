defmodule PrometheusEcto.Mixfile do
  use Mix.Project

  @version "1.4.3"

  def project do
    [
      app: :prometheus_ecto,
      version: @version,
      elixir: "~> 1.3",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: [
        main: Prometheus.EctoInstrumenter,
        source_ref: "v#{@version}",
        source_url: "https://github.com/deadtrickster/prometheus-ecto"
      ]
    ]
  end

  def application do
    [applications: [:logger, :prometheus_ex]]
  end

  defp description do
    """
    Prometheus monitoring system client Ecto integration. Observes queries duration.
    """
  end

  defp package do
    [
      maintainers: ["Ilya Khaprov"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/deadtrickster/prometheus-ecto",
        "Prometheus.erl" => "https://hex.pm/packages/prometheus",
        "Prometheus.ex" => "https://hex.pm/packages/prometheus_ex",
        "Plugs Instrumenter/Exporter" => "https://hex.pm/packages/prometheus_plugs",
        "Phoenix Instrumenter" => "https://hex.pm/packages/prometheus_phoenix",
        "Process info Collector" => "https://hex.pm/packages/prometheus_process_collector"
      }
    ]
  end

  defp deps do
    [
      {:prometheus_ex, "~> 1.1 or ~> 2.0 or ~> 3.0"},
      {:ecto, "~> 2.0 or ~> 3.0"},
      {:mariaex, ">= 0.0.0", only: :test},
      {:ex_doc, "~> 0.11", only: :dev},
      {:earmark, ">= 0.0.0", only: :dev},
      {:credo, github: "rrrene/credo", only: [:dev, :test], runtime: false, app: false}
    ]
  end
end
