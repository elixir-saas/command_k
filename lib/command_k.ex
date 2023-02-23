defmodule CommandK do
  @moduledoc """
  Documentation for `CommandK`.
  """

  defmacro __using__(opts) do
    handler = Keyword.fetch!(opts, :handler)
    component = Keyword.fetch!(opts, :component)

    quote do
      on_mount({unquote(__MODULE__.LiveView), {:default, unquote(handler), unquote(component)}})
    end
  end

  ## Delegates

  alias Phoenix.LiveView.JS

  defdelegate put_context(socket, context), to: __MODULE__.LiveView

  defdelegate open(js \\ %JS{}), to: __MODULE__.LiveView
  defdelegate close(js \\ %JS{}), to: __MODULE__.LiveView
  defdelegate toggle(js \\ %JS{}), to: __MODULE__.LiveView
  defdelegate exec(js \\ %JS{}, id), to: __MODULE__.LiveView
  defdelegate command_k(js \\ %JS{}), to: __MODULE__.LiveView

  defdelegate send_open(), to: __MODULE__.LiveView
  defdelegate send_close(), to: __MODULE__.LiveView
  defdelegate send_toggle(), to: __MODULE__.LiveView
  defdelegate send_exec(id, context), to: __MODULE__.LiveView
end
