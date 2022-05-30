defmodule Ssg.MixProject do
  use Mix.Project

  def project do
    [
      app: :ssg,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def escript do
    [main_module: SSG.CLI]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:earmark, "~> 1.4"},
      {:expug, "~> 0.9.2"},
      {:phoenix_html, "~> 3.2"}
    ]
  end
end
