defmodule Timer.ClockTest do
  use Timer.DataCase

  alias Timer.Clock

  describe "games" do
    alias Timer.Clock.Game

    import Timer.ClockFixtures

    @invalid_attrs %{
      count_down_minutes: nil,
      display_ends: nil,
      finish_extension: nil,
      warning_minutes: nil
    }

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Clock.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Clock.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      valid_attrs = %{
        count_down_minutes: 42,
        display_ends: true,
        finish_extension: 42,
        warning_minutes: 42
      }

      assert {:ok, %Game{} = game} = Clock.create_game(valid_attrs)
      assert game.count_down_minutes == 42
      assert game.display_ends == true
      assert game.finish_extension == 42
      assert game.warning_minutes == 42
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clock.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()

      update_attrs = %{
        count_down_minutes: 43,
        display_ends: false,
        finish_extension: 43,
        warning_minutes: 43
      }

      assert {:ok, %Game{} = game} = Clock.update_game(game, update_attrs)
      assert game.count_down_minutes == 43
      assert game.display_ends == false
      assert game.finish_extension == 43
      assert game.warning_minutes == 43
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Clock.update_game(game, @invalid_attrs)
      assert game == Clock.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Clock.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Clock.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Clock.change_game(game)
    end
  end

  describe "games" do
    alias Timer.Clock.Game

    import Timer.ClockFixtures

    @invalid_attrs %{
      count_down_minutes: nil,
      display_ends: nil,
      finish_extension: nil,
      number_of_ends: nil,
      sheet: nil,
      warning_minutes: nil
    }

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Clock.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Clock.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      valid_attrs = %{
        count_down_minutes: 42,
        display_ends: true,
        finish_extension: 42,
        number_of_ends: 42,
        sheet: 42,
        warning_minutes: 42
      }

      assert {:ok, %Game{} = game} = Clock.create_game(valid_attrs)
      assert game.count_down_minutes == 42
      assert game.display_ends == true
      assert game.finish_extension == 42
      assert game.number_of_ends == 42
      assert game.sheet == 42
      assert game.warning_minutes == 42
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clock.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()

      update_attrs = %{
        count_down_minutes: 43,
        display_ends: false,
        finish_extension: 43,
        number_of_ends: 43,
        sheet: 43,
        warning_minutes: 43
      }

      assert {:ok, %Game{} = game} = Clock.update_game(game, update_attrs)
      assert game.count_down_minutes == 43
      assert game.display_ends == false
      assert game.finish_extension == 43
      assert game.number_of_ends == 43
      assert game.sheet == 43
      assert game.warning_minutes == 43
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Clock.update_game(game, @invalid_attrs)
      assert game == Clock.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Clock.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Clock.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Clock.change_game(game)
    end
  end
end
