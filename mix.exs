defmodule LibreTranslate.MixProject do
  use Mix.Project

  def project do
    [
      app: :libre_translate_ex,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "libre_translate_ex",
      source_url: "https://github.com/bonfire-networks/libre_translate_ex",
      homepage_url: "https://hex.pm/packages/libre_translate_ex",
      docs: &docs/0
    ]
  end

  defp description do
    "Elixir client library for the LibreTranslate machine translation API."
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/bonfire-networks/libre_translate_ex"}
    ]
  end

  defp docs do
    [
    ]
  end


  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Core
      {:req, "~> 0.5.0"},

      # Documentation
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},

      # Development & testing
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0", only: :test},
      {:styler, "~> 1.2", only: [:dev, :test], runtime: false}
    ]
  end
end
