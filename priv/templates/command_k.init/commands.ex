defmodule <%= inspect @web_module %>.Commands do
  use <%= inspect @web_module %>, :verified_routes

  import Phoenix.LiveView

  # List commands

  def list_commands(:global, _input) do
    [
      {:nav_home, name: "Navigate to home", icon: &Heroicons.link/1}
    ]
  end

  # Handle commands

  def handle_command(:nav_home, _context, socket) do
    push_navigate(socket, to: ~p"/")
  end
end
