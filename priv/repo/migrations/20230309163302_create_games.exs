defmodule Timer.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :sheet, :string, null: false
      add :count_down_minutes, :integer, default: 90, null: false
      add :number_of_ends, :integer, default: 8, null: false
      add :warning_minutes, :integer, default: 10, null: true
      add :display_ends, :boolean, default: true, null: false
      add :finish_extension, :integer, default: 2, null: false
      add :ticks, :integer, default: 1001, null: false
      add :start_minute, :integer, default: 0, null: false
      add :ip_address, :string
      add :pause, :boolean, default: false, null: false
      add :start_time, :naive_datetime
      add :timer_pid, :string
      add(:user_id, references(:users, type: :binary_id, on_delete: :delete_all, null: false))
    end

    create index(:games, [:user_id])
    create index(:games, [:timer_pid])
    create unique_index(:games, [:user_id, :sheet])
    create unique_index(:games, [:ip_address])
  end
end
