defmodule Grimoire.Repo.Migrations.AddSourceTypeAndUrlToFeeds do
  use Ecto.Migration

  def change do
    alter table(:feeds) do
      add :source_type, :string, null: false
      add :source_url, :map, null: false
    end
  end
end
