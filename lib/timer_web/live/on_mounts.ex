defmodule TimerUsWeb.OnMounts do
  import Phoenix.Component
  import Phoenix.LiveView
  use TimerWeb, :verified_routes
  alias Timer.Accounts

  def on_mount(
        :require_authenticated_user,
        _params,
        %{"user_token" => user_token} = _session,
        socket
      ) do
    socket =
      assign_new(socket, :current_user, fn ->
        Accounts.get_user_by_session_token(user_token)
      end)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: ~p"/users/log_in")}
    end
  end

  def on_mount(:require_authenticated_user, _params, _session, socket) do
    {:halt, redirect(socket, to: ~p"/users/log_in")}
  end
end
