defmodule ExClockBoundClient.MixProject do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :ex_clock_bound_client,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      description: description(),
      source_url: github_url()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExClockBoundClient.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"Github" => github_url()}
    ]
  end

  defp github_url do
    "https://github.com/smartepsh/ex_clock_bound_client"
  end

  defp description do
    "The elixir version of aws clock bound client"
  end

  defp docs do
    [
      main: "readme",
      source_url: github_url(),
      source_ref: "v#{@version}",
      extras: ["README.md", "LICENSE"]
    ]
  end
end
