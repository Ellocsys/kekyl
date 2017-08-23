defmodule Kekyl.Repo.Migrations.ModifyLastCommitField do
  use Ecto.Migration

  def change do
    alter table(:github_repo) do
      modify :last_commit, :date, [null: false, default: fragment("now()")]
    end
  end
end
