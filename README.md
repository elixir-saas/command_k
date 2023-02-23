# CommandK

Command+K implementation for Phoenix LiveView.

## Installation

Install by adding `command_k` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:command_k, "~> 0.1.0"}
  ]
end
```

View additional documentation at <https://hexdocs.pm/command_k>.

## Getting Started

CommandK includes an easy install task to bootstrap your app code:

```sh
$ mix command_k.init     
* creating lib/my_app_web/commands.ex
* injecting lib/my_app_web/components/core_components.ex
```

This task will provide your app with a boilerplate command handler module
in `my_app_web/commands.ex`, and extend your existing `core_components.ex` file
to include a baseline command palette component implementation.

Once you have these, configure CommandK by specifying them in the `live_view` section
in your web module:

```ex
def live_view do
  quote do
    use Phoenix.LiveView,
      layout: {MyAppWeb.Layouts, :app}

    use CommandK,
      handler: MyAppWeb.Commands,
      component: &MyAppWeb.CoreComponents.command_k_palette/1

    unquote(html_helpers())
  end
end
```

Lastly, we need to make an adjustment to our client side code in `assets/app.js` in
order for our LiveView application to detect meta key presses (holding "command"):

```js
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
```

You may refer to the documentation on Key Events for more information as to why
we need to do this: https://hexdocs.pm/phoenix_live_view/bindings.html#key-events

## Usage

To render a `CommandK.LiveComponent`, add the following to your app layout template:

```html
<.live_component
  id="command_k"
  module={CommandK.LiveComponent}
  command_k={@command_k}
  command_k_context={@command_k_context}
  show={@command_k_show}
  on_cancel={CommandK.close()}
/>
```

The assigns `@command_k`, `@command_k_show`, and `@command_k_context` are automatically
injected by the library. This live component will render using the function component that was
previously specified in your web module.

Next, add the following `phx-` bindings to any element also in your app layout template:

```html
<main
  class="..."
  phx-window-keydown={CommandK.command_k()}
  phx-key="k"
>
  ...
</main>
```

You can tell CommandK to open the palette manually by calling `CommandK.open()`:

```html
<.button class="absolute right-4 bottom-4" phx-click={CommandK.open()}>
  Command+K
</.button>
```

See the `CommandK` module for more information.

TODO: Add code documentation, expand on usage section here.
