defmodule TimerWeb.GameLive.Index do
  use TimerWeb, :live_view

  alias Timer.Clock
  alias Timer.Clock.Game

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    socket = assign(socket, :games1, Clock.list_games(current_user))
    {:ok, stream(socket, :games, Clock.list_games(current_user))}
  end

  @impl true
  def handle_params(params, _url, %{assigns: %{current_user: current_user}} = socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, current_user, params)}
  end

  defp apply_action(socket, :edit, current_user, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Timer")
    |> assign(:game, Clock.get_game!(current_user, id))
  end

  defp apply_action(socket, :upload_logo, _current_user, _params) do
    socket
    |> assign(:page_title, "Change Logo")
    |> assign(:game, nil)
  end

  defp apply_action(socket, :new, _current_user, _params) do
    socket
    |> assign(:page_title, "New Timer")
    |> assign(:game, %Game{
      sheet: "A",
      ip_address: "127.0.0.1",
      count_down_minutes: 90,
      number_of_ends: 8,
      warning_minutes: 15,
      display_ends: true,
      finish_extension: 2,
      start_minute: 0,
      ticks: 0,
      pause: true,
      default_game: false
    })
  end

  defp apply_action(socket, :index, _current_user, _params) do
    socket
    |> assign(:page_title, "Listing Timers")
    |> assign(:game, nil)
  end

  defp apply_action(socket, :default, current_user, _params) do
    cond do
      game = Clock.get_default_game(current_user) ->
        socket |> push_redirect(to: ~p"/games/#{game}")

      game = Clock.get_latest_game(current_user) ->
        socket |> push_redirect(to: ~p"/games/#{game}")

      true ->
        socket |> push_redirect(to: ~p"/games")
    end
  end

  @impl true
  def handle_info({TimerWeb.GameLive.FormComponent, {:saved, game}}, socket) do
    {:noreply, stream_insert(socket, :games, game)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, %{assigns: %{current_user: current_user}} = socket) do
    game = Clock.get_game!(current_user, id)
    {:ok, _} = Clock.delete_game(game)

    {:noreply,
     socket
     |> push_redirect(to: ~p"/games")}
  end
end
