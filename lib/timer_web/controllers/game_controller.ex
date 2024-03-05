defmodule TimerWeb.GameController do
  use TimerWeb, :controller

  alias Timer.Clock
  alias Timer.Clock.Game

  action_fallback TimerWeb.FallbackController

  def index(conn, _params) do
    games = Clock.list_games(conn.assigns.currrent_user)
    render(conn, :index, games: games)
  end

  def create(conn, %{"game" => game_params}) do
    with {:ok, %Game{} = game} <- Clock.create_game(conn.assigns.currrent_user, game_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/games/#{game}")
      |> render(:show, game: game)
    end
  end

  def show(conn, %{"id" => id}) do
    game = Clock.get_game!(conn.assigns.currrent_user, id)
    render(conn, :show, game: game)
  end

  def update(conn, %{"id" => id, "game" => game_params}) do
    game = Clock.get_game!(conn.assigns.currrent_user, id)

    with {:ok, %Game{} = game} <- Clock.update_game(conn.assigns.currrent_user, game, game_params) do
      render(conn, :show, game: game)
    end
  end

  def delete(conn, %{"id" => id}) do
    game = Clock.get_game!(conn.assigns.currrent_user, id)

    with {:ok, %Game{}} <- Clock.delete_game(game) do
      send_resp(conn, :no_content, "")
    end
  end
end
