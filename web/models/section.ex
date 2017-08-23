defmodule Kekyl.Section do
  use Kekyl.Web, :model

  schema "sections" do
    field :name, :string
    field :link, :string
    has_many :contents, Kekyl.Content

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :link])
    |> validate_required([:name, :link])
  end
end
