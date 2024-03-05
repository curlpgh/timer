defmodule Timer.Repo.Migrations.AddTimeStampsAndDefaultToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :default_game, :boolean, null: false, default: false
      timestamps()
    end
  end
end
