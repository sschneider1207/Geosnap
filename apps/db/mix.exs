defmodule Geosnap.Db.Mixfile do
  use Mix.Project

  def project do
    [app: :geosnap_db,
     version: "0.0.1",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :postgrex, :ecto, :geo, :timex, :timex_ecto],
     mod: {Geosnap.Db.App, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:myapp, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ecto, "~> 2.0"},
     {:postgrex, "~> 0.11.2"},
     {:geo, "~> 1.1"},
     {:geosnap_encryption, in_umbrella: true, path: "../encryption"},
     {:timex, "~> 3.0"},
     {:timex_ecto, "~> 3.0"}]
  end
end
