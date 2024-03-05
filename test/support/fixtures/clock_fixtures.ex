defmodule Timer.ClockFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Timer.Clock` context.
  """

  @doc """
  Generate a game.
  """
  def game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> Enum.into(%{
        count_down_minutes: 42,
        display_ends: true,
        finish_extension: 42,
        number_of_ends: 42,
        sheet: 42,
        warning_minutes: 42
      })
      |> Timer.Clock.create_game()

    game
  end
end
