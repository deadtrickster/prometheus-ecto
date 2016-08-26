defmodule PrometheusEcto.Mixfile do
  use Mix.Project

  def project do
    [app: :prometheus_ecto,
     version: "0.0.6",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps()]
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
    [maintainers: ["Ilya Khaprov"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/deadtrickster/prometheus-ecto",
              "Prometheus.erl" => "https://hex.pm/packages/prometheus",
              "Prometheus.ex" => "https://hex.pm/packages/prometheus_ex",
              "Plugs Instrumenter/Exporter" => "https://hex.pm/packages/prometheus_plugs",
              "Phoenix Instrumenter" => "https://hex.pm/packages/prometheus_phoenix",
              "Process info Collector" => "https://hex.pm/packages/prometheus_process_collector"}]
  end
  
  defp deps do
    [{:prometheus_ex, "~> 0.0.3"},
     {:ecto, "~> 2.0"},
     {:mariaex, ">= 0.0.0", only: :test}]
  end
end
