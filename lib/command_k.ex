defmodule CommandK do
  @moduledoc """
  Documentation for `CommandK`.
  """

  defmacro __using__(opts) do
    handler = Keyword.fetch!(opts, :handler)

    quote do
      on_mount({unquote(__MODULE__.LiveView), {:default, unquote(handler)}})
    end
  end

  ## Delegates

  defdelegate open(), to: __MODULE__.LiveView
  defdelegate close(), to: __MODULE__.LiveView
  defdelegate toggle(), to: __MODULE__.LiveView

  defdelegate send_open(), to: __MODULE__.LiveView
  defdelegate send_close(), to: __MODULE__.LiveView
  defdelegate send_toggle(), to: __MODULE__.LiveView
  defdelegate send_exec(id, context), to: __MODULE__.LiveView
end
