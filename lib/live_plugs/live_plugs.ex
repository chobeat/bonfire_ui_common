defmodule Bonfire.UI.Common.LivePlugs do
  @moduledoc "Like a plug, but for a liveview"
  alias Bonfire.UI
  use UI.Common

  # TODO: put in config
  @default_plugs [
    UI.Common.LivePlugs.StaticChanged,
    UI.Common.LivePlugs.Csrf,
    UI.Common.LivePlugs.Locale
  ]

  # Bonfire.UI.Common.LivePlugs.AllowTestSandbox

  def on_mount(modules, params, session, socket) when is_list(modules) do
    UI.Common.undead_on_mount(socket, fn ->
      socket = init_mount(params, session, socket)

      case Enum.reduce_while(modules ++ @default_plugs, socket, fn module, socket ->
             with {:halt, socket} <-
                    maybe_apply(module, :on_mount, [:default, params, session, socket]) do
               # to halt both the reduce and the on_mount
               {:halt, {:halt, socket}}
             end
           end) do
        {:halt, socket} -> {:halt, socket}
        {:cont, socket} -> mount_done(socket)
        socket -> mount_done(socket)
      end
    end)
  end

  def on_mount(module, params, session, socket) when is_atom(module) do
    UI.Common.undead_on_mount(socket, fn ->
      with {:cont, socket} <-
             init_mount(params, session, socket)
             |> maybe_apply(module, :on_mount, [:default, params, session, ...]) do
        mount_done(socket)
      end
    end)
  end

  defp init_mount(:not_mounted_at_router, session, socket) do
    # for embedding views in views/components using `live_render`
    # note that these views can't contain any handle_params
    init_mount(stringify_keys(session["params"]), session, socket)
  end

  defp init_mount(params, _session, socket) do
    with {:ok, socket} <-
           socket
           |> Phoenix.LiveView.attach_hook(
             :params_to_assigns,
             :handle_params,
             &params_to_assigns/3
           )
           #  |> Phoenix.LiveView.attach_hook(
           #    :send_persistent_assigns_after_render,
           #    :after_render,
           #    &send_persistent_assigns_after_render/1
           #  )
           |> init_socket(params, ...) do
      socket
    end
  rescue
    e in RuntimeError ->
      # workaround to `cannot attach hook with id :params_to_assigns on :handle_params because the view was not mounted at the router with the live/3 macro` on hybrid views
      warn(e)
      init_socket(params, socket)
  end

  defp init_socket(params, socket) do
    current_app = Application.get_application(socket.view)
    current_extension = Bonfire.Common.ExtensionModule.extension(current_app)

    if not is_nil(current_app) and
         (not extension_enabled?(current_app, :instance) or
            not extension_enabled?(current_app, socket)) do
      if not extension_enabled?(current_app, :instance) do
        error(
          l(
            "Sorry, %{app} is not enabled on this instance. You may want to get in touch with your instance admin(s)...",
            app: current_extension[:name] || current_app
          )
        )
      else
        error(
          l("You have not enabled %{app}. You can do so in Settings -> Extensions.",
            app: current_extension[:name] || current_app
          )
        )
      end
    else
      Bonfire.Common.TestInstanceRepo.maybe_declare_test_instance(socket.endpoint)

      debug(Phoenix.LiveView.connected?(socket), "init socket")

      {:ok,
       if(module_enabled?(Surface), do: Surface.init(socket), else: socket)
       |> assign_global(
         current_view: socket.view,
         current_app: current_app,
         current_extension: current_extension,
         current_params: params,
         live_action: e(socket, :assigns, :live_action, nil),
         socket_connected?: Phoenix.LiveView.connected?(socket)
       )}
    end
  end

  defp mount_done(socket) do
    {:cont,
     assign_global(
       socket,
       ui_compact: Settings.get([:ui, :compact], nil, socket.assigns)
     )}

    # |> debug()
  end

  def send_persistent_assigns_after_render(socket) do
    maybe_send_persistent_assigns(socket)

    socket
  end

  def maybe_send_persistent_assigns(assigns \\ nil, socket) do
    # in case we're browsing between LVs, send some assigns (eg current_user, page_title, etc to PersistentLive's process)
    if socket_connected?(socket),
      do:
        Bonfire.UI.Common.PersistentLive.maybe_send_assigns(
          assigns || socket.assigns
          # |> Map.new()
          # |> Map.put_new(:nav_items, nil)
        )
  end

  defp params_to_assigns(params, uri, socket) do
    socket = assign_default_params(params, uri, socket)

    # in case we're browsing between LVs, send assigns (eg current_user to PersistentLive's process)
    if socket_connected?(socket), do: maybe_send_persistent_assigns(socket)

    {:cont, socket}
  end

  def assign_default_params(params, uri, socket) do
    uri = URI.parse(uri)

    socket
    |> assign_global(
      current_params: params,
      current_url: "#{uri.path}##{uri.fragment}"
    )
    |> Iconify.maybe_set_favicon(
      e(socket.assigns, :current_extension, :emoji, nil) ||
        e(socket.assigns, :current_extension, :icon, nil)
    )
  end
end
