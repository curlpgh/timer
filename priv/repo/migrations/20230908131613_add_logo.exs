defmodule Timer.Repo.Migrations.AddLogo do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :logo, :string
    end
  end
end
