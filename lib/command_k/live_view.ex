defmodule CommandK.LiveView do
  require Logger

  import Phoenix.Component
  import Phoenix.LiveView

  alias Phoenix.LiveView.JS

  @prefix "@command_k:"

  @key :command_k
  @show_key :command_k_show
  @context_key :command_k_context

  ## Mount

  def on_mount({:default, handler, component}, _params, _session, socket) do
    config = %{
      handler: handler,
      component: component
    }

    socket =
      socket
      |> assign(@key, config)
      |> assign(@show_key, false)
      |> assign(@context_key, %{})
      |> attach_hook(:__command_k_event, :handle_event, &handle_event/3)
      |> attach_hook(:__command_k_info, :handle_info, &handle_info/2)

    {:cont, socket}
  end

  def put_context(socket, context), do: assign(socket, @context_key, context)

  ## Events

  def open(js \\ %JS{}), do: JS.push(js, @prefix <> "open")
  def close(js \\ %JS{}), do: JS.push(js, @prefix <> "close")
  def toggle(js \\ %JS{}), do: JS.push(js, @prefix <> "toggle")
  def exec(js \\ %JS{}, id), do: JS.push(js, @prefix <> "exec", value: %{command_id: id})
  def command_k(js \\ %JS{}), do: JS.push(js, @prefix <> "command_k")

  defp handle_event(@prefix <> event, params, socket) do
    case {event, params} do
      {"open", _} ->
        {:halt, do_open(socket)}

      {"close", _} ->
        {:halt, do_close(socket)}

      {"toggle", _} ->
        {:halt, do_toggle(socket)}

      {"exec", %{"command_id" => id}} ->
        id = String.to_existing_atom(id)
        context = socket.assigns[:command_k_context]
        {:halt, do_exec(socket, id, context)}

      {"command_k", %{"key" => "k", "metaKey" => true, "repeat" => false}} ->
        {:halt, do_toggle(socket)}

      _otherwise ->
        warn_on_missing_key_meta(event, params)
        {:halt, socket}
    end
  end

  defp handle_event(_event, _params, socket), do: {:cont, socket}

  ## Messsages

  def send_open(), do: send(self(), {__MODULE__, :open})
  def send_close(), do: send(self(), {__MODULE__, :close})
  def send_toggle(), do: send(self(), {__MODULE__, :toggle})
  def send_exec(id, context), do: send(self(), {__MODULE__, {:exec, id, context}})

  defp handle_info({__MODULE__, message}, socket) do
    case message do
      :open ->
        {:halt, do_open(socket)}

      :close ->
        {:halt, do_close(socket)}

      :toggle ->
        {:halt, do_toggle(socket)}

      {:exec, id, context} ->
        {:halt, do_exec(socket, id, context)}
    end
  end

  defp handle_info(_info, socket), do: {:cont, socket}

  ## Helpers

  defp do_open(socket), do: assign(socket, @show_key, true)
  defp do_close(socket), do: assign(socket, @show_key, false)
  defp do_toggle(socket), do: update(socket, @show_key, &(not &1))

  defp do_exec(socket, id, context) do
    handler = get_config(socket.assigns).handler
    do_close(handler.handle_command(id, context, socket))
  end

  def get_config(assigns), do: assigns[@key]

  defp warn_on_missing_key_meta(event, params) do
    case {event, params} do
      {event, _params} when event != "command_k" ->
        :ok

      {"command_k", %{"metaKey" => _, "repeat" => _}} ->
        :ok

      _otherwise ->
        Logger.warn(missing_key_meta_warning())
    end
  end

  defp missing_key_meta_warning() do
    """
    No key metadata found in event!

    CommandK is not currently able to detect when the "command" key is being held down.

    Update the liveSocket in your app.js file to send metaKey and repeat information:

        let liveSocket = new LiveSocket("/live", Socket, {
          params: {_csrf_token: csrfToken},
          metadata: {
            keydown: (e, el) => {
              return {
                key: e.key,
                metaKey: e.metaKey,
                repeat: e.repeat
              }
            }
          }
        })

    See the documentation on Key Events for more information:

        https://hexdocs.pm/phoenix_live_view/bindings.html#key-events
    """
  end
end
