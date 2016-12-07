defmodule PhotoFieldTest do
  use ExUnit.Case
  alias Geosnap.Db

  setup_all do
    on_exit(&delete_all_pictures/0)
  end

  test "new with invalid params returns error map" do
    {:error, errors} = PhotoField.new(%{})

    assert is_map(errors) == true
  end

  test "new with valid params returns picture" do
    user = TestHelper.user()
    category = TestHelper.category()
    result =
      %{user_id: user.id, category_id: category.id}
      |> TestHelper.picture_params()
      |> PhotoField.new()

    assert {:ok, _picture} = result
  end

  test "can get picture by id" do
    {_user, _category, picture} = TestHelper.new_picture()
    other_picture = PhotoField.get(picture.id)

    assert picture.id == other_picture.id
  end

  test "get picture with non existant id returns nil" do
    picture = PhotoField.get(1)

    assert is_nil(picture) == true
  end

  defp delete_all_pictures do
    Db.Repo.delete_all(Db.Picture)
  end
end
