defmodule ExAws.KinesisVideo.MixProject do
  use Mix.Project

  @source_url "https://github.com/JasonTrue/ex_aws_kinesis_video"
  @version "0.1.0"
  @name __MODULE__ |> Module.split() |> Enum.take(2) |> Enum.join(".")

  def project do
    [
      app: :jasontrue_ex_aws_kinesis_video,
      version: @version,
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: "AWS Kinesis Video Client (compatible with ExAws)",
      name: @name,
      package: package(),
      docs: [main: @name, source_ref: "v#{@version}", source_url: @source_url, extras: ["README.md"]],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_add_apps: [:ex_unit],
        plt_file:
          {:no_warn, "priv/plts/dialyzer_#{System.version()}_otp#{System.otp_release()}.plt"}
      ]
    ]
  end

  def aliases do
    [
      precommit: ["deps.get", "format"],
      prepush: [
        "deps.get",
        "format --check-formatted",
        "compile --warnings-as-errors",
        "cmd mix test",
        "dialyzer"
      ]
    ]
  end

  def package do
    [
      description: "#{@name} service package",
      files: ["lib", "config", "mix.exs", "README*"],
      maintainers: ["Jason Truesdell"],
      licenses: ["MIT"],
      links: %{GitHub: @source_url}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev},
      ex_aws()
    ]
  end

  defp ex_aws() do
    case System.get_env("AWS") do
      "LOCAL" -> {:ex_aws, path: "../ex_aws"}
      _ -> {:ex_aws, "~> 2.0"}
    end
  end
end
