
  @doc """
  Renders a command palette modal, designed to work with CommandK.
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :commands, :list, required: true
  attr :selected_index, :integer, required: true
  attr :on_cancel, JS, default: %JS{}
  attr :target, :string, required: true

  def command_k_palette(assigns) do
    ~H"""
    <div
      id={@id}
      class="relative z-50 hidden"
      role="dialog"
      aria-modal="true"
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
    >
      <div id={"#{@id}-bg"} class="fixed inset-0 bg-zinc-500 bg-opacity-25 transition-opacity"></div>
      <div class="fixed inset-0 z-10 overflow-y-auto p-4 sm:p-6 md:p-20">
        <.focus_wrap
          id={"#{@id}-container"}
          phx-mounted={@show && show_modal(@id)}
          phx-window-keydown={hide_modal(@on_cancel, @id)}
          phx-key="escape"
          phx-click-away={hide_modal(@on_cancel, @id)}
          class="mx-auto max-w-xl transform rounded-xl bg-white p-2 shadow-2xl ring-1 ring-black ring-opacity-5 transition-all"
        >
          <.form
            :let={f}
            id={"#{@id}-content"}
            for={%{}}
            as={:command}
            phx-change="change"
            phx-submit="submit"
            phx-target={@target}
          >
            <input
              id={f[:input].id}
              name={f[:input].name}
              value={f[:input].value}
              phx-keydown="input_key"
              phx-target={@target}
              class="w-full rounded-md border-0 bg-zinc-100 px-4 py-2.5 placeholder-zinc-500 text-zinc-900 sm:text-sm focus:outline-none"
              autocomplete="off"
              placeholder="Search..."
              role="combobox"
              aria-expanded="false"
              aria-controls="options"
            />
          </.form>

          <ul
            class="-mb-2 max-h-72 scroll-py-2 overflow-y-auto py-2 text-sm text-zinc-800"
            id="options"
            role="listbox"
          >
            <li
              :for={{{id, opts}, index} <- Enum.with_index(Enum.take(@commands, 10))}
              class={[
                if(@selected_index == index, do: "bg-zinc-100"),
                "cursor-pointer select-none rounded-md flex items-center px-4 py-2 hover:bg-zinc-100"
              ]}
              phx-click={CommandK.exec(id)}
              role="option"
              tabindex="-1"
            >
              <CommandK.Component.dynamic
                :if={icon = opts[:icon]}
                component={icon}
                class="mr-3 h-4 w-4 text-zinc-400"
              />
              <%%= Keyword.fetch!(opts, :name) %>
            </li>
          </ul>

          <div :if={@commands == []} class="py-14 px-4 text-center sm:px-14">
            <Heroicons.magnifying_glass class="mx-auto h-6 w-6 text-zinc-400" />
            <p class="mt-4 text-sm text-zinc-900">No commands found that match your search</p>
          </div>
        </.focus_wrap>
      </div>
    </div>
    """
  end
