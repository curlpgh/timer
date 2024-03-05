defmodule Timer.Clock do
  @moduledoc """
  The Clock context.
  """

  import Ecto.Query, warn: false
  alias Timer.Repo
  alias Ecto.Multi
  alias Timer.Clock.Game
  alias Timer.Accounts.User

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games(%User{} = user) do
    from(g in Game, where: g.user_id == ^user.id) |> Repo.all()
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(%User{} = user, id) do
    from(g in Game, where: g.id == ^id and g.user_id == ^user.id) |> Repo.one!()
  end

  def get_game_by_sheet!(%User{} = user, sheet) do
    from(g in Game, where: g.sheet == ^sheet and g.user_id == ^user.id) |> Repo.one!()
  end

  def get_default_game(%User{} = user) do
    from(g in Game, where: g.user_id == ^user.id and g.default_game == true, limit: 1)
    |> Repo.one()
  end

  def get_latest_game(%User{} = user) do
    from(g in Game, where: g.user_id == ^user.id, order_by: [desc: g.updated_at], limit: 1)
    |> Repo.one()
  end

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(%User{} = user, attrs \\ %{}) do
    multi =
      Multi.new()
      |> Multi.insert(:game, Game.changeset(%Game{}, attrs))
      |> Multi.run(:update_default_game, fn _repo, %{game: game} ->
        if game.default_game do
          # set all other games to default = false
          from(g in Game,
            where: g.user_id == ^user.id,
            where: g.id != ^game.id,
            update: [set: [default_game: false]]
          )
          |> Repo.update_all([])

          {:ok, game}
        else
          {:ok, game}
        end
      end)

    case Repo.transaction(multi) do
      {:ok, result} ->
        {:ok, result.update_default_game}

      {:error, _, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a game while editing

  ## Examples

      iex> update_game(user, game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(user, game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%User{} = user, %Game{} = game, %{"start_minute" => start_minute} = attrs) do
    attrs = Map.merge(attrs, %{"ticks" => String.to_integer(start_minute) * 1000 * 60})

    multi =
      Multi.new()
      |> Multi.update(:game, Game.changeset(game, attrs))
      |> Multi.run(:update_default_game, fn _repo, %{game: game} ->
        if game.default_game do
          # set all other games to default = false
          from(g in Game,
            where: g.user_id == ^user.id,
            where: g.id != ^game.id,
            update: [set: [default_game: false]]
          )
          |> Repo.update_all([])

          {:ok, game}
        else
          {:ok, game}
        end
      end)

    case Repo.transaction(multi) do
      {:ok, result} ->
        {:ok, result.update_default_game}

      {:error, _, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a game while the clock is running
  """
  def update_game(%Game{} = game, %{ticks: ticks} = attrs) do
    start_minute = (ticks / 1000 / 60) |> trunc()
    attrs = Map.merge(attrs, %{start_minute: start_minute})

    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{data: %Game{}}

  """
  def change_game(%Game{} = game, attrs \\ %{}) do
    Game.changeset(game, attrs)
  end

  def game_status(%Game{} = game) do
    total_seconds = game.count_down_minutes * 60
    seconds_elapsed = min(Integer.floor_div(game.ticks, 1000), total_seconds)
    percent_complete = (seconds_elapsed / total_seconds * 100) |> trunc() |> min(100)
    total_seconds_remaining = total_seconds - seconds_elapsed

    number_of_ends_under_timer = max(game.number_of_ends - game.finish_extension, 1)
    seconds_per_end = total_seconds / number_of_ends_under_timer

    end_they_should_be_on =
      (number_of_ends_under_timer - total_seconds_remaining / seconds_per_end + 1)
      |> trunc()
      |> max(1)
      |> min(number_of_ends_under_timer)

    {hours_remaining, minutes_remaining, seconds_remaining} =
      if Integer.floor_div(total_seconds_remaining, 60) > 90 do
        # greate than 90 minutes left so show hours
        hours_remaining = Integer.floor_div(total_seconds_remaining, 3600) |> min(99)

        minutes_remaining =
          Integer.floor_div(total_seconds_remaining - hours_remaining * 3600, 60)

        seconds_remaining =
          total_seconds_remaining - hours_remaining * 3600 - minutes_remaining * 60

        {hours_remaining, minutes_remaining, seconds_remaining}
      else
        minutes_remaining = Integer.floor_div(total_seconds_remaining, 60)

        seconds_remaining = total_seconds_remaining - minutes_remaining * 60

        {0, minutes_remaining, seconds_remaining}
      end

    progress =
      Enum.reduce(1..number_of_ends_under_timer, [], fn e, acc ->
        progress =
          cond do
            seconds_elapsed in ((e - 1) * trunc(seconds_per_end))..(e * trunc(seconds_per_end)) ->
              ((seconds_elapsed - (e - 1) * seconds_per_end) / seconds_per_end * 100)
              |> Float.round()

            seconds_elapsed < (e - 1) * seconds_per_end ->
              0

            seconds_elapsed > e * seconds_per_end ->
              100
          end

        [progress | acc]
      end)
      |> Enum.reverse()

    game =
      Map.merge(game, %{
        number_of_ends_under_timer: number_of_ends_under_timer,
        end_they_should_be_on: end_they_should_be_on,
        hours_remaining: hours_remaining,
        minutes_remaining: minutes_remaining,
        seconds_remaining: seconds_remaining,
        percent_complete: percent_complete,
        progress: progress,
        total_seconds_remaining: total_seconds_remaining
      })

    if Application.fetch_env!(:timer, :environment) == :dev do
      IO.inspect("percent: #{seconds_elapsed / total_seconds * 100}")
      IO.inspect("seconds_elapsed: #{seconds_elapsed}")
      IO.inspect("total_seconds: #{total_seconds}")
      IO.inspect("total_seconds remaining: #{total_seconds_remaining}")
      IO.inspect("number_of_ends_under_timer: #{number_of_ends_under_timer}")
      IO.inspect("seconds_per_end: #{seconds_per_end}")
      IO.inspect("minutes_per_end: #{round(seconds_per_end / 60)}")
      IO.inspect("progress: ")
      IO.inspect(progress)
      IO.inspect(game)
      game
    else
      game
    end
  end
end
