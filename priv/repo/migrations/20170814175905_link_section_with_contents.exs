defmodule Kekyl.Repo.Migrations.LinkSectionWithContents do
  use Ecto.Migration

  def change do

    alter table(:contents) do
      add :section_id, references(:sections)
    end

    create index(:contents, [:section_id])
  end
end
