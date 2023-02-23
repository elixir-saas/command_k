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
