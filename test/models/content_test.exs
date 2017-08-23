defmodule Kekyl.ContentTest do
  use Kekyl.ModelCase

  alias Kekyl.Content

  @valid_attrs %{link: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Content.changeset(%Content{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Content.changeset(%Content{}, @invalid_attrs)
    refute changeset.valid?
  end
end
