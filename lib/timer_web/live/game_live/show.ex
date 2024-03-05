defmodule TimerWeb.GameLive.Show do
  use TimerWeb, :live_view

  alias Timer.Clock

  @one_second :timer.seconds(1)

  @impl true
  def mount(_params, _session, socket) do
    timer_reference = Process.send_after(self(), :tick, @one_second)
    {:ok, socket |> assign(timer_reference: timer_reference)}
  end

  @impl true
  def handle_params(
        %{"id" => id},
        _url,
        %{assigns: %{current_user: current_user, live_action: live_action}} = socket
      ) do
    {:noreply, apply_action(socket, Clock.get_game!(current_user, id), live_action)}
  end

  def handle_params(
        %{"sheet" => sheet},
        _url,
        %{assigns: %{current_user: current_user, live_action: live_action}} = socket
      ) do
    {:noreply, apply_action(socket, Clock.get_game_by_sheet!(current_user, sheet), live_action)}
  end

  defp apply_action(socket, game, :show) do
    {:ok, game} = Clock.update_game(game, %{start_time: nil})

    socket
    |> assign(game: game)
    |> assign(background_colour: background_colour(game))
    |> assign(:page_title, "Timer")
  end

  defp apply_action(%{assigns: %{game: game}} = socket, _game, :start_timer) do
    # make sure it's unpaused
    {:ok, game} = Clock.update_game(game, %{pause: false})
    socket |> assign(game: game) |> cycle()
  end

  defp apply_action(
         %{assigns: %{game: game, timer_reference: timer_reference}} = socket,
         _game,
         :stop_timer
       ) do
    Process.cancel_timer(timer_reference)
    timer_reference = Process.send_after(self(), :tick, @one_second)
    {:ok, game} = Clock.update_game(game, %{pause: true})

    socket
    |> assign(game: game)
    |> assign(timer_reference: timer_reference)
  end

  #  reset ticks and start again
  defp apply_action(%{assigns: %{game: game}} = socket, _game, :restart_timer) do
    {:ok, game} =
      Clock.update_game(game, %{
        pause: true,
        start_time: NaiveDateTime.local_now(),
        ticks: 0
      })

    socket |> assign(game: game) |> cycle()
  end

  @impl true
  def handle_info(:tick, %{assigns: %{game: game}} = socket) when game.pause do
    {:noreply, pause(socket)}
  end

  def handle_info(:tick, %{assigns: %{game: game, timer_reference: timer_reference}} = socket) do
    if game && game.percent_complete && game.percent_complete >= 100 do
      Process.cancel_timer(timer_reference)
      {:noreply, socket}
    else
      {:noreply, cycle(socket)}
    end
  end

  def handle_info(:tick, socket) do
    {:noreply, cycle(socket)}
  end

  defp cycle(%{assigns: %{game: game}} = socket) when is_nil(game.start_time) do
    # hasn't started yet
    timer_reference = Process.send_after(self(), :tick, @one_second)

    ticks = game.start_minute * 60 * 1000
    start_time = NaiveDateTime.add(NaiveDateTime.local_now(), -ticks, :millisecond)
    {:ok, game} = Clock.update_game(game, %{ticks: ticks, start_time: start_time})

    game = Clock.game_status(game)

    socket
    |> assign(game: game)
    |> assign(timer_reference: timer_reference)
    |> assign(background_colour: background_colour(game))
  end

  defp cycle(%{assigns: %{game: game}} = socket) do
    timer_reference = Process.send_after(self(), :tick, @one_second)

    now = NaiveDateTime.local_now()

    elapsed_ticks = NaiveDateTime.diff(now, game.start_time, :millisecond)
    {:ok, game} = Clock.update_game(game, %{ticks: elapsed_ticks})

    game = Clock.game_status(game)

    socket
    |> assign(game: game)
    |> assign(timer_reference: timer_reference)
    |> assign(background_colour: background_colour(game))
  end

  defp pause(%{assigns: %{game: game}} = socket) when is_nil(game.start_time) do
    # hasn't started yet
    timer_reference = Process.send_after(self(), :tick, @one_second)

    ticks = game.start_minute * 60 * 1000
    start_time = NaiveDateTime.add(NaiveDateTime.local_now(), -ticks, :millisecond)
    {:ok, game} = Clock.update_game(game, %{ticks: ticks, start_time: start_time})

    game = Clock.game_status(game)

    socket
    |> assign(game: game)
    |> assign(timer_reference: timer_reference)
    |> assign(background_colour: background_colour(game))
  end

  defp pause(%{assigns: %{game: game}} = socket) do
    # Bump the start time up by the amount of the delay. Do not update the
    # game status. It will display the last time before pause.
    timer_reference = Process.send_after(self(), :tick, @one_second)
    now = NaiveDateTime.local_now()
    elapsed_ticks = NaiveDateTime.diff(now, game.start_time, :millisecond)

    {:ok, game} =
      Clock.update_game(game, %{
        start_time: NaiveDateTime.add(game.start_time, elapsed_ticks - game.ticks, :millisecond)
      })

    game = Clock.game_status(game)

    socket
    |> assign(game: game)
    |> assign(timer_reference: timer_reference)
    |> assign(background_colour: background_colour(game))
  end

  defp background_colour(game) do
    cond do
      game.total_seconds_remaining <= 0 ->
        "bg_timeout"

      game.total_seconds_remaining > game.warning_minutes * 60 ->
        "bg_running"

      game.total_seconds_remaining <= game.warning_minutes * 60 ->
        "bg_warning"
    end
  end
end
