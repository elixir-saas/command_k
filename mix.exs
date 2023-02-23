defmodule CommandK.MixProject do
  use Mix.Project

  @version "0.1.2"

  def project do
    [
      app: :command_k,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp description() do
    "Command+K implementation for Phoenix LiveView"
  end

  defp package() do
    [
      licenses: ["Apache-2.0"],
      links: %{}
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix,
       git: "https://github.com/phoenixframework/phoenix.git",
       tag: "v1.7.0-rc.3",
       only: :dev,
       override: true},
      {:phoenix_live_view, "~> 0.18.14"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
