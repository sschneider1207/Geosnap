defmodule PhotoField.PhotoTest do
  use ExUnit.Case
  alias PhotoField.Photo

  test "expired pictures are not spawned" do
    params = TestHelper.picture_params(%{expiration: Timex.now() |> Timex.shift([hours: -1])})
    picture = struct(Geosnap.Db.Picture, params)
    {:error, reason} = Photo.start_link(picture)

    assert reason == :expired
  end
end
