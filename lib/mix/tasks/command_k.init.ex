defmodule Mix.Tasks.CommandK.Init do
  use Mix.Task

  @shortdoc "Generates boilerplate code for a Command+K palette"

  def generator_paths(), do: [".", :command_k]

  @impl true
  def run(args) do
    if args != [] do
      Mix.raise("mix command_k.init does not accept any arguments")
    end

    if Mix.Project.umbrella?() do
      Mix.raise(
        "mix command_k.init must be invoked from within your *_web application root directory"
      )
    end

    ctx_app = Mix.Phoenix.context_app()

    base = Mix.Phoenix.base()
    binding = [assigns: [web_module: Mix.Phoenix.web_module(base)]]

    commands_file = Mix.Phoenix.web_path(ctx_app, "commands.ex")
    core_components_file = Mix.Phoenix.web_path(ctx_app, "components/core_components.ex")

    Mix.Phoenix.copy_from(generator_paths(), "priv/templates/command_k.init", binding, [
      {:eex, "commands.ex", commands_file}
    ])

    inject_eex_before_final_end(
      Mix.Phoenix.eval_from(
        generator_paths(),
        "priv/templates/command_k.init/core_components_command_k_palette.ex",
        binding
      ),
      core_components_file
    )
  end

  defp inject_eex_before_final_end(content_to_inject, file_path) do
    file = File.read!(file_path)

    if String.contains?(file, content_to_inject) do
      :ok
    else
      Mix.shell().info([:green, "* injecting ", :reset, Path.relative_to_cwd(file_path)])

      file
      |> String.trim_trailing()
      |> String.trim_trailing("end")
      |> Kernel.<>(content_to_inject)
      |> Kernel.<>("end\n")
      |> then(&File.write!(file_path, &1))
    end
  end
end
