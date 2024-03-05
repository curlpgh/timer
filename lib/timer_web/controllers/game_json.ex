defmodule TimerWeb.GameJSON do
  alias Timer.Clock.Game

  @doc """
  Renders a list of games.
  """
  def index(%{games: games}) do
    %{data: for(game <- games, do: data(game))}
  end

  @doc """
  Renders a single game.
  """
  def show(%{game: game}) do
    %{data: data(game)}
  end

  defp data(%Game{} = game) do
    %{
      id: game.id,
      sheet: game.sheet,
      count_down_minutes: game.count_down_minutes,
      number_of_ends: game.number_of_ends,
      warning_minutes: game.warning_minutes,
      display_ends: game.display_ends,
      finish_extension: game.finish_extension
    }
  end
end
