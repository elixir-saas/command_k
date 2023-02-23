defmodule CommandK.LiveComponent do
  use Phoenix.LiveComponent

  import CommandK.Component, only: [dynamic: 1]

  def render(assigns) do
    ~H"""
    <div phx-window-keydown={CommandK.command_k()} phx-key="k">
      <.dynamic
        :if={@show}
        {assigns}
        id={@id <> "_inner"}
        component={CommandK.LiveView.get_config(assigns).component}
        target={@myself}
      />
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> put_commands()}
  end

  def handle_event("input_key", params, socket) do
    commands = socket.assigns.commands
    selected_index = socket.assigns.selected_index

    case params do
      %{"key" => "Escape"} ->
        CommandK.send_toggle()
        {:noreply, socket}

      %{"key" => key} when key in ["ArrowDown", "ArrowRight"] ->
        selected_index = min(selected_index + 1, length(commands) - 1)
        {:noreply, assign(socket, :selected_index, selected_index)}

      %{"key" => key} when key in ["ArrowUp", "ArrowLeft"] ->
        selected_index = max(selected_index - 1, 0)
        {:noreply, assign(socket, :selected_index, selected_index)}

      %{"key" => "k", "metaKey" => true, "repeat" => false} ->
        CommandK.send_toggle()
        {:noreply, socket}

      _otherwise ->
        {:noreply, socket}
    end
  end

  def handle_event("change", %{"command" => %{"input" => input}}, socket) do
    {:noreply, put_commands(socket, input)}
  end

  def handle_event("submit", %{"command" => %{"input" => input}}, socket) do
    commands = socket.assigns.commands
    selected_index = socket.assigns.selected_index

    case Enum.at(commands, selected_index) do
      nil ->
        CommandK.send_toggle()

        {:noreply, socket}

      {id, opts} ->
        context = Keyword.get(opts, :context, %{})
        context = Map.put(context, :input, input)

        CommandK.send_exec(id, context)

        {:noreply, socket}
    end
  end

  defp put_commands(socket, input \\ "") do
    handler = CommandK.LiveView.get_config(socket.assigns).handler

    local_commands? = function_exported?(socket.view, :list_commands, 2)

    commands =
      if local_commands? do
        socket.view.list_commands(socket.assigns[:command_k_context], input) ++
          handler.list_commands(:global, input)
      else
        handler.list_commands(:global, input)
      end
      |> filter_commands(input)

    socket
    |> assign(:commands, commands)
    |> assign(:selected_index, 0)
  end

  defp filter_commands(commands, input) do
    normalize = &String.downcase(String.replace(&1, ~r/\s/, ""))
    Enum.filter(commands, fn {_id, opts} -> normalize.(opts[:name]) =~ normalize.(input) end)
  end
end
