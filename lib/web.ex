defmodule Bonfire.UI.Common.Web do
  @moduledoc false

  alias Bonfire.Common.Utils

  def controller(opts \\ []) do
    opts =
      Keyword.put_new(
        opts,
        :namespace,
        Bonfire.Common.Config.get(:default_web_namespace, Bonfire.UI.Common)
      )

    quote do
      use Phoenix.Controller, unquote(opts)
      import Plug.Conn
      alias Bonfire.UI.Common.Plugs.MustBeGuest
      alias Bonfire.UI.Common.Plugs.MustLogIn

      import Phoenix.LiveView.Controller

      unquote(live_view_basic_helpers())
    end
  end

  def view(opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:root, "lib")
      |> maybe_put_layout("app.html")

    quote do
      use Phoenix.View, unquote(opts)

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # to support Surface components in the app layout and in non-LiveViews
      use Surface.View, unquote(opts)
      # Bonfire.Common.Extend.quoted_use_if_enabled(Surface.View)

      Bonfire.Common.Extend.quoted_import_if_enabled(Surface)

      unquote(live_view_helpers())
    end
  end

  defp maybe_put_layout(opts, file) do
    Keyword.put_new(
      opts,
      :layout,
      {Bonfire.Common.Config.get(
         :default_layout_module,
         Bonfire.UI.Common.LayoutView
       ), file}
    )
  end

  def layout_view(opts \\ []) do
    view(opts)
  end

  def live_view(opts \\ []) do
    # IO.inspect(live_view: opts)
    opts = maybe_put_layout(opts, "live.html")

    quote do
      use Phoenix.LiveView, unquote(opts)

      unquote(live_view_helpers())

      # TODO: replace LivePlugs with on_mount?
      import Bonfire.UI.Common.LivePlugs

      # on_mount(PhoenixProfiler)
    end
  end

  def live_component(opts \\ []) do
    quote do
      use Phoenix.LiveComponent, unquote(opts)

      unquote(live_view_helpers())
    end
  end

  def function_component(opts \\ []) do
    quote do
      use Phoenix.Component, unquote(opts)

      unquote(live_view_helpers())
    end
  end

  def live_handler(_opts \\ []) do
    quote do
      import Phoenix.LiveView
      import Phoenix.Component
      alias Bonfire.UI.Common.ComponentID

      unquote(view_helpers())
    end
  end

  def live_plug(_opts \\ []) do
    quote do
      unquote(common_helpers())

      import Phoenix.LiveView
      import Phoenix.Component
    end
  end

  def plug(_opts \\ []) do
    quote do
      unquote(common_helpers())

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def router(opts \\ []) do
    quote do
      use Phoenix.Router, unquote(opts)
      unquote(common_helpers())

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router

      # unquote(Bonfire.Common.Extend.quoted_use_if_enabled(Thesis.Router))
    end
  end

  def channel(opts \\ []) do
    quote do
      use Phoenix.Channel, unquote(opts)
      import Untangle
    end
  end

  defp common_helpers do
    quote do
      use Bonfire.UI.Common

      # localisation
      require Bonfire.Common.Localise.Gettext
      import Bonfire.Common.Localise.Gettext.Helpers

      # deprecated: Phoenix's Helpers
      alias Bonfire.Web.Router.Helpers, as: Routes

      # use instead: Bonfire's voodoo routing, eg: `path(Bonfire.UI.Social.FeedsLive):
      import Bonfire.Common.URIs

      alias Bonfire.Me.Settings
      alias Bonfire.Common.Config
      import Config, only: [repo: 0]

      import Bonfire.Common.Extend

      import Untangle
      import Bonfire.UI.Common.ErrorHelpers
    end
  end

  defp basic_view_helpers do
    quote do
      unquote(common_helpers())

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # unquote(Bonfire.Common.Extend.quoted_use_if_enabled(Thesis.View, Bonfire.PublisherThesis.ContentAreas))

      import Bonfire.Common.Modularity.DeclareExtensions
    end
  end

  defp view_helpers do
    quote do
      unquote(basic_view_helpers())

      # Import basic rendering functionality (render, render_layout, etc)
      # import Phoenix.View

      # unquote(Bonfire.Common.Extend.quoted_use_if_enabled(Thesis.View, Bonfire.PublisherThesis.ContentAreas))
    end
  end

  defp live_view_helpers do
    quote do
      unquote(live_view_basic_helpers())

      # Import component helpers
      import Phoenix.Component
    end
  end

  defp live_view_basic_helpers do
    quote do
      unquote(view_helpers())

      alias Bonfire.UI.Common.ComponentID

      alias Phoenix.LiveView.JS

      # Import Surface if any dep is using it
      Bonfire.Common.Extend.quoted_import_if_enabled(Surface)
    end
  end

  if Bonfire.Common.Extend.module_exists?(Surface) do
    def surface_live_view(opts \\ []) do
      opts =
        maybe_put_layout(
          opts,
          "live.html"
        )

      quote do
        use Surface.LiveView, unquote(opts)

        unquote(surface_helpers())

        import Bonfire.UI.Common.LivePlugs

        # on_mount(PhoenixProfiler)
      end
    end

    def stateful_component(opts \\ []) do
      quote do
        use Surface.LiveComponent, unquote(opts)

        unquote(surface_component_helpers())
      end
    end

    def stateless_component(opts \\ []) do
      quote do
        use Surface.Component, unquote(opts)

        unquote(surface_component_helpers())
      end
    end

    defp surface_component_helpers do
      quote do
        unquote(surface_helpers())

        data current_account, :any, from_context: :current_account
        data current_user, :any, from_context: :current_user
      end
    end

    defp surface_helpers do
      quote do
        unquote(live_view_basic_helpers())

        # prop current_account, :any
        # prop current_user, :any

        alias Surface.Components.Dynamic

        alias Surface.Components.Link
        alias Surface.Components.Link.Button
        alias Surface.Components.LivePatch
        alias Surface.Components.LiveRedirect

        alias Surface.Components.Form
        alias Surface.Components.Form.Field
        alias Surface.Components.Form.FieldContext
        alias Surface.Components.Form.Label
        alias Surface.Components.Form.ErrorTag
        alias Surface.Components.Form.Inputs
        alias Surface.Components.Form.HiddenInput
        alias Surface.Components.Form.HiddenInputs
        alias Surface.Components.Form.TextInput
        alias Surface.Components.Form.TextArea
        alias Surface.Components.Form.NumberInput
        alias Surface.Components.Form.RadioButton
        alias Surface.Components.Form.Select
        alias Surface.Components.Form.MultipleSelect
        alias Surface.Components.Form.OptionsForSelect
        alias Surface.Components.Form.DateTimeSelect
        alias Surface.Components.Form.TimeSelect
        alias Surface.Components.Form.Checkbox
        alias Surface.Components.Form.ColorInput
        alias Surface.Components.Form.DateInput
        alias Surface.Components.Form.TimeInput
        alias Surface.Components.Form.DateTimeLocalInput
        alias Surface.Components.Form.EmailInput
        alias Surface.Components.Form.PasswordInput
        alias Surface.Components.Form.RangeInput
        alias Surface.Components.Form.SearchInput
        alias Surface.Components.Form.TelephoneInput
        alias Surface.Components.Form.UrlInput
        alias Surface.Components.Form.FileInput
        alias Surface.Components.Form.TextArea

        alias Bonfire.UI.Common.LazyImage
      end
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defmacro __using__({which, opts}) when is_atom(which) and is_list(opts) do
    apply(__MODULE__, which, [opts])
  end
end
