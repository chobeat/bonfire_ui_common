defmodule Bonfire.UI.Common.LayoutLive do
  @moduledoc """
  A simple Surface stateless component that sets default assigns needed for every view (eg. used in nav) and then shows some global components and the @inner_content
  """
  use Bonfire.UI.Common.Web, :stateless_component

  def render(assigns) do
    current_app = assigns[:__context__][:current_app]
    # |> debug("current_app")

    nav_items =
      assigns[:nav_items] ||
        Bonfire.Common.ExtensionModule.default_nav(current_app) ||
        Bonfire.Common.NavModule.nav(current_app)

    # Note: since this is not a Surface component, we need to set default props this way
    # TODO: make this list of assigns config-driven so other extensions can add what they need?
    assigns =
      assigns
      # |> debug
      |> assign(to_boundaries: boundaries_or_default(e(assigns, :to_boundaries, nil), assigns))
      |> assign_new(:nav_header, fn ->
        if is_nil(current_user(assigns)),
          do: Bonfire.UI.Common.GuestHeaderLive,
          else: Bonfire.UI.Common.LoggedHeaderLive
      end)
      |> assign_new(:hero, fn -> nil end)
      |> assign_new(:page_title, fn -> nil end)
      |> assign_new(:without_mobile_logged_header, fn -> nil end)
      |> assign_new(:full_page, fn -> false end)
      |> assign_new(:page, fn -> nil end)
      |> assign_new(:selected_tab, fn -> nil end)
      |> assign_new(:notification, fn -> nil end)
      |> assign_new(:page_header_aside, fn -> nil end)
      |> assign_new(:page_header_drawer, fn -> false end)
      |> assign_new(:custom_page_header, fn -> nil end)
      |> assign_new(:inner_content, fn -> nil end)
      |> assign_new(:object_id, fn -> nil end)
      |> assign_new(:post_id, fn -> nil end)
      |> assign_new(:context_id, fn -> nil end)
      |> assign_new(:reply_to_id, fn -> nil end)
      |> assign_new(:create_object_type, fn -> nil end)
      |> assign_new(:to_circles, fn -> [] end)
      |> assign_new(:smart_input_prompt, fn -> nil end)
      |> assign_new(:smart_input_opts, fn -> nil end)
      |> assign_new(:smart_input_as, fn ->
        Bonfire.UI.Common.SmartInputLive.set_smart_input_as(assigns[:thread_mode], assigns)
      end)
      |> assign_new(:showing_within, fn -> nil end)
      |> assign_new(:sidebar_widgets, fn -> [] end)
      |> assign_new(:nav_items, fn -> nav_items end)
      |> assign_new(:without_sidebar, fn -> nil end)
      #     fn -> (not is_nil(current_user(assigns)) &&
      #         empty?(e(assigns, :sidebar_widgets, :users, :main, nil))) ||
      #        (!is_nil(current_user(assigns)) &&
      #           empty?(e(assigns, :sidebar_widgets, :guests, :main, nil)))
      # end)
      |> assign_new(:hide_smart_input, fn -> false end)
      |> assign_new(:thread_mode, fn -> nil end)
      |> assign_new(:show_less_menu_items, fn -> false end)
      |> assign_new(:preview_module, fn -> nil end)
      |> assign_new(:preview_assigns, fn -> nil end)

    # |> debug()

    ~F"""
    <div x-data={"{
        open_extensions_sidebar: false,
        toggle_sidebar_widgets: false,
      }"}>
      <!--<Bonfire.UI.Common.SmartInputContainerLive
        :if={not is_nil @current_user}
        hide_smart_input={@hide_smart_input}
        showing_within={@showing_within}
        reply_to_id={@reply_to_id}
        context_id={@context_id}
        create_object_type={@create_object_type}
        thread_mode={@thread_mode}
        without_sidebar={@without_sidebar}
        to_boundaries={@to_boundaries}
        to_circles={@to_circles}
        smart_input_as={@smart_input_as}
        smart_input_prompt={@smart_input_prompt}
        smart_input_opts={@smart_input_opts}
      />-->
      {if not is_nil(@current_user),
        do:
          live_render(@socket, Bonfire.UI.Common.SmartInputContainerLive,
            sticky: true,
            id: :smart_input_sticky,
            session: %{
              "__context__" =>
                Map.merge(@__context__, %{
                  # avoid too big a session
                  current_user: ulid(@current_user),
                  current_account: ulid(@current_account)
                }),
              "hide_smart_input" => @hide_smart_input,
              "showing_within" => @showing_within,
              "reply_to_id" => @reply_to_id,
              "context_id" => @context_id,
              "create_object_type" => @create_object_type,
              "thread_mode" => @thread_mode,
              "without_sidebar" => @without_sidebar,
              "to_boundaries" => @to_boundaries,
              "to_circles" => @to_circles,
              "smart_input_as" => @smart_input_as,
              "smart_input_prompt" => @smart_input_prompt,
              "smart_input_opts" => @smart_input_opts
            }
          )}

      <Dynamic.Component
        :if={@nav_header != false and module_enabled?(@nav_header, @current_user)}
        module={@nav_header}
        page_header_aside={@page_header_aside}
        page_title={@page_title}
        page={@page}
        page_header_drawer={e(@page_header_drawer, false)}
        hide_smart_input={@hide_smart_input}
        without_mobile_logged_header={@without_mobile_logged_header}
        showing_within={@showing_within}
        reply_to_id={e(@reply_to_id, "")}
        context_id={@context_id}
        create_object_type={@create_object_type}
        thread_mode={@thread_mode}
        without_sidebar={@without_sidebar}
        custom_page_header={@custom_page_header}
        to_boundaries={@to_boundaries}
        to_circles={@to_circles}
        smart_input_as={@smart_input_as}
        smart_input_prompt={@smart_input_prompt}
        smart_input_opts={@smart_input_opts}
        sidebar_widgets={@sidebar_widgets}
        nav_items={e(@nav_items, [])}
      />

      <div id="bonfire_live" class="transition duration-150 ease-in-out transform">
        <!-- :class="{'ml-[240px]': open_extensions_sidebar}" -->
        <div
          x-data="{
            open_sidebar_drawer: false,
            open_drawer: false,
            width: window.innerWidth,
          }"
          @resize.window.debounce.100="width = window.innerWidth"
          class={
            "w-full items-start mx-auto grid grid-cols-1 md:grid-cols-[300px_minmax(min-content,_1fr)]",
            "!grid-cols-1": @without_sidebar || is_nil(@current_user)
          }
        >
          <div
            :if={!@without_sidebar && @current_user}
            class="border-r border-base-content/10 overflow-y-auto overflow-x-hidden widget hidden z-[110]  md:block sticky top-[56px]"
          >
            <Bonfire.UI.Common.NavSidebarLive
              page={@page}
              selected_tab={@selected_tab}
              nav_items={@nav_items}
              sidebar_widgets={@sidebar_widgets}
              hide_smart_input={@hide_smart_input}
              showing_within={@showing_within}
              reply_to_id={e(@reply_to_id, "")}
              context_id={@context_id}
              create_object_type={@create_object_type}
              thread_mode={@thread_mode}
              without_sidebar={@without_sidebar}
              to_boundaries={@to_boundaries}
              to_circles={@to_circles}
              smart_input_as={@smart_input_as}
              smart_input_prompt={@smart_input_prompt}
              smart_input_opts={@smart_input_opts}
            />
          </div>

          <div
            id="main_section"
            class={
              "gap-2 md:gap-0 relative z-[105] w-full col-span-1",
              "!max-w-full mx-auto": @without_sidebar,
              "!max-w-full": @full_page
            }
          >
            <div class={
              "mt-0 grid tablet-lg:grid-cols-[1fr_300px] desktop-lg:grid-cols-[1fr_420px] grid-cols-1",
              "md:mt-6": @nav_header == false,
              "!grid-cols-1": @current_user && !is_list(@sidebar_widgets[:users][:secondary]),
              "!grid-cols-1": is_nil(@current_user) && !is_list(@sidebar_widgets[:guests][:secondary]),
              "max-w-screen-lg gap-4 mx-auto": is_nil(@current_user),
              "justify-between": @current_user
            }>
              <div class={
                "relative grid invisible_frame",
                "": @current_user && !@without_sidebar
              }>
                <div class="pb-16 md:pb-0 md:overflow-y-visible md:h-full">
                  <Bonfire.UI.Common.PreviewContentLive id="preview_content" />
                  <div id="inner" class="">
                    <!-- Bonfire.UI.Common.ExtensionHorizontalMenuLive
                    nav_items={@nav_items}
                    page={@page}
                    selected_tab={@selected_tab}
                    /-->
                    {@inner_content}
                  </div>
                </div>
              </div>

              <div
                :if={(is_list(@sidebar_widgets[:users][:secondary]) and not is_nil(ulid(@current_user))) or
                  (is_list(@sidebar_widgets[:guests][:secondary]) and is_nil(ulid(@current_user)))}
                x-show={if @preview_module, do: "false", else: "true"}
                class={
                  "items-start hidden min-h-[calc(100vh-56px)] grid-flow-row gap-6 overflow-x-hidden overflow-y-auto md:pt-3 auto-rows-min tablet-lg:grid",
                  "px-6 border-l border-base-content/10": @current_user
                }
              >
                <!-- USER WIDGET SIDEBAR -->
                <Dynamic.Component
                  :if={not is_nil(ulid(@current_user))}
                  :for={{component, component_assigns} <-
                    @sidebar_widgets[:users][:secondary] ||
                      [
                        {Bonfire.Tag.Web.WidgetTagsLive, []},
                        {Bonfire.UI.Common.WidgetFeedbackLive, []}
                      ]}
                  module={component}
                  {...component_assigns}
                />

                <!-- GUEST WIDGET SIDEBAR -->
                <Dynamic.Component
                  :if={is_nil(ulid(@current_user))}
                  :for={{component, component_assigns} <- @sidebar_widgets[:guests][:secondary] || []}
                  module={component}
                  {...component_assigns}
                />
              </div>
            </div>
          </div>
        </div>
      </div>
      <Bonfire.UI.Common.MobileSmartInputButtonLive
        :if={not is_nil(@current_user) and !@hide_smart_input}
        smart_input_prompt={@smart_input_prompt}
      />
      <Bonfire.UI.Common.NavFooterMobileUserLive :if={not is_nil(@current_user)} page={@page} />

      <!--      {if module_enabled?(RauversionExtension.UI.TrackLive.Player, @current_user),
        do:
          live_render(@socket, RauversionExtension.UI.TrackLive.Player,
            id: "global-main-player",
            session: %{},
            sticky: true
          )} -->
    </div>

    <Bonfire.UI.Common.ReusableModalLive id="modal" />

    <Bonfire.UI.Common.NotificationLive
      id="notification"
      notification={@notification}
      root_flash={@flash}
    />
    """
  end
end
