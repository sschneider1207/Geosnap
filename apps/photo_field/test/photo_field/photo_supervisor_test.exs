defmodule PhotoField.PhotoSupervisorTest do
  use ExUnit.Case
  alias PhotoField.PhotoSupervisor

  test "pictures die when expired" do
    {_user, _category, picture} = TestHelper.new_picture()
    picture = %{picture | expiration: Timex.now() |> Timex.shift([seconds: 2])}
    {:ok, pid} = PhotoSupervisor.spawn_photo(picture)
    Process.sleep(2_000)

    assert Process.alive?(pid) == false
  end
end
