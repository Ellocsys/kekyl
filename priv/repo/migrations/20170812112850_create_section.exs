defmodule Kekyl.Repo.Migrations.CreateSection do
  use Ecto.Migration

  def change do
    create table(:sections) do
      add :name, :string
      add :link, :string

      timestamps()
    end

  end
end
