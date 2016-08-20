defmodule PrometheusEcto.Mixfile do
  use Mix.Project

  def project do
    [app: :prometheus_ecto,
     version: "0.0.4",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps()]
  end
  
  def application do
    [applications: [:logger, :prometheus]]
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
              "Plugs" => "https://github.com/deadtrickster/prometheus-plugs",
              "Phoenix Instrumenter" => "https://github.com/deadtrickster/prometheus-phoenix"}]
  end
  
  defp deps do
    [{:prometheus, "~> 2.0"},
     {:ecto, "~> 2.0"},
     {:mariaex, ">= 0.0.0", only: :test}]
  end
end
