defmodule CommandK.Component do
  use Phoenix.Component

  attr(:component, :any, required: true)
  attr(:rest, :global)

  def dynamic(assigns) do
    Phoenix.LiveView.HTMLEngine.component(
      assigns.component,
      assigns.rest,
      {__ENV__.module, __ENV__.function, __ENV__.file, __ENV__.line}
    )
  end
end
