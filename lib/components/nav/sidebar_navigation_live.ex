defmodule Bonfire.UI.Common.SidebarNavigationLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop page, :string, required: true
  prop hide_smart_input, :boolean
  
end
