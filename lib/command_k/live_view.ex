defmodule CommandK.LiveView do
  import Phoenix.Component
  import Phoenix.LiveView

  alias Phoenix.LiveView.JS

  @prefix "@command_k:"
  @show_key :command_k_show
  @handler_key :command_k_handler

  ## Mount

  def on_mount({:default, handler}, _params, _session, socket) do
    socket =
      socket
      |> assign(@show_key, false)
      |> assign(@handler_key, handler)
      |> attach_hook(:__command_k_event, :handle_event, &handle_event/3)
      |> attach_hook(:__command_k_info, :handle_info, &handle_info/2)

    {:cont, socket}
  end

  ## Events

  def open(js \\ %JS{}), do: JS.push(js, @prefix <> "open")
  def close(js \\ %JS{}), do: JS.push(js, @prefix <> "close")
  def toggle(js \\ %JS{}), do: JS.push(js, @prefix <> "toggle")
  def command_k(js \\ %JS{}), do: JS.push(js, @prefix <> "command_k")

  defp handle_event(@prefix <> event, params, socket) do
    case {event, params} do
      {"open", _} ->
        {:halt, do_open(socket)}

      {"close", _} ->
        {:halt, do_close(socket)}

      {"toggle", _} ->
        {:halt, do_toggle(socket)}

      {"command_k", %{"metaKey" => true, "repeat" => false}} ->
        {:halt, do_toggle(socket)}

      _otherwise ->
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
        socket = get_handler(socket).handle_command(id, context, socket)
        {:halt, do_close(socket)}
    end
  end

  defp handle_info(_info, socket), do: {:cont, socket}

  ## Helpers

  defp do_open(socket), do: assign(socket, @show_key, true)
  defp do_close(socket), do: assign(socket, @show_key, false)
  defp do_toggle(socket), do: update(socket, @show_key, &(not &1))

  defp get_handler(socket), do: socket.assigns[@handler_key]
end
