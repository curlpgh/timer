defmodule Timer.Clock.Game do
  use Ecto.Schema
  import Ecto.Changeset
  alias Timer.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "games" do
    field :sheet, :string
    field :count_down_minutes, :integer, default: 90
    field :number_of_ends, :integer, default: 8
    field :display_ends, :boolean, default: true
    field :finish_extension, :integer, default: 2
    field :ticks, :integer
    field :ip_address, :string
    field :warning_minutes, :integer
    field :start_minute, :integer
    field :pause, :boolean, default: false
    field :default_game, :boolean, default: true
    field :timer_pid, :string
    field :start_time, :naive_datetime
    field :end_they_should_be_on, :integer, virtual: true
    field :hours_remaining, :integer, virtual: true
    field :minutes_remaining, :integer, virtual: true
    field :seconds_remaining, :integer, virtual: true
    field :percent_complete, :integer, virtual: true
    field :number_of_ends_under_timer, :integer, virtual: true
    field :progress, :map, virtual: true
    field :total_seconds_remaining, :integer, virtual: true
    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [
      :sheet,
      :count_down_minutes,
      :number_of_ends,
      :warning_minutes,
      :display_ends,
      :finish_extension,
      :ticks,
      :ip_address,
      :start_time,
      :start_minute,
      :pause,
      :default_game,
      :timer_pid,
      :user_id
    ])
    |> validate_required([
      :sheet,
      :count_down_minutes,
      :number_of_ends,
      :display_ends,
      :finish_extension,
      :start_minute,
      :user_id
    ])
    |> validate_length(:sheet, max: 200)
    |> unique_constraint(:sheet, name: :games_user_id_sheet_index)
    |> validate_inclusion(:count_down_minutes, 1..360, message: "must be 1 to 360 minutes")
    |> validate_inclusion(:number_of_ends, 1..12, message: "must be 1 to 12 ends")
    |> validate_inclusion(:finish_extension, 0..2, message: "must be 0, 1, or 2 ends")
    |> validate_inclusion(:warning_minutes, 0..360, message: "must be 1 to 360 minutes")
    |> validate_warning_minutes()
    |> validate_number(:start_minute, greater_than_or_equal_to: 0)
    |> validate_start_minute()
  end

  defp validate_warning_minutes(changeset) do
    if get_change(changeset, :warning_minutes) do
      if get_field(changeset, :warning_minutes) > get_field(changeset, :count_down_minutes) do
        Ecto.Changeset.add_error(
          changeset,
          :warning_minutes,
          "cannot be more than count down minutes"
        )
      else
        changeset
      end
    else
      changeset
    end
  end

  defp validate_start_minute(changeset) do
    if get_change(changeset, :start_minute) do
      if get_field(changeset, :start_minute) > get_field(changeset, :count_down_minutes) do
        Ecto.Changeset.add_error(
          changeset,
          :start_minute,
          "cannot start after count down minutes"
        )
      else
        changeset
      end
    else
      changeset
    end
  end
end
