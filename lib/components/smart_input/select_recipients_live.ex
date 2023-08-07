defmodule Bonfire.UI.Common.SelectRecipientsLive do
  use Bonfire.UI.Common.Web, :stateless_component

  # prop target_component, :string
  prop preloaded_recipients, :list, default: nil
  prop to_boundaries, :any, default: nil
  prop to_circles, :list, default: []
  prop exclude_circles, :list, default: []
  prop context_id, :string, default: nil
  prop showing_within, :atom, default: nil
  prop implementation, :any, default: :live_select
  prop label, :string, default: nil
  prop mode, :atom, default: :tags
  prop class, :string, default: "w-full h-10 input rounded-full select_recipients_input"
  prop is_editable, :boolean, default: false

  def do_handle_event("live_select_change", %{"id" => live_select_id, "text" => search}, socket) do
    debug(live_select_id, search)
    # current_user = current_user(socket)

    Bonfire.Me.Users.search(search)
    |> results_for_multiselect()
    |> maybe_send_update(LiveSelect.Component, live_select_id, options: ...)

    {:noreply, socket}
  end

  def do_handle_event(
        "multi_select",
        %{data: %{"field" => field, "id" => id, "username" => username}},
        socket
      ) do
    {:noreply,
     socket
     |> update(maybe_to_atom(field) |> debug("f"), fn current_to_circles ->
       (List.wrap(current_to_circles) ++ [{id, username}])
       |> debug("v")
     end)}
  end

  def do_handle_event(
        "multi_select",
        %{data: data},
        socket
      )
      when is_list(data) do
    first = List.first(data)

    field =
      maybe_to_atom(e(first, :field, :to_circles))
      |> debug("field")

    updated =
      Enum.map(
        data,
        &{id(&1), e(&1, "username", nil)}
      )
      |> filter_empty([])
      |> debug("new value")

    if updated != e(socket.assigns, field, nil) |> debug("existing") do
      {:noreply,
       socket
       |> assign(
         field,
         Enum.uniq(updated) 
         |> debug("update value")
       )}
    else
      {:noreply, socket}
    end
  end

  def results_for_multiselect(results) do
    results
    |> Enum.map(fn
      # %Bonfire.Data.AccessControl.Circle{} = circle ->
      #   {e(circle, :named, :name, nil) || e(circle, :sterotyped, :named, :name, nil),
      #    %{id: e(circle, :id, nil), field: :to_circles}}

      user ->
        {"#{e(user, :profile, :name, nil)} - #{e(user, :character, :username, nil)}",
         %{
           id: e(user, :id, nil),
           field: :to_circles,
           icon: Media.avatar_url(user),
           username: e(user, :character, :username, nil)
         }}
    end)
    # Filter to remove any nils
    |> Enum.filter(fn {name, _} -> name != nil end)
    |> debug()
  end
end
