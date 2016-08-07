:ok = Application.ensure_started(:geosnap_db)

alias Geosnap.Db.{Repo, Application, ApiKey, Category, User, Picture}

IO.puts "Inserting seed data"

{:ok, app} = 
  Application.new_changeset(%{name: "test app", email: "test@example.com"})
  |> Repo.insert()

{:ok, apikey} =
  ApiKey.new_changeset(app.id)
  |> Repo.insert()

{:ok, category} =
  Category.new_changeset("sports")
  |> Repo.insert()

{:ok, user} =
  %{
    username: "test_user",
    password: "password123",
    email: "test@example.com"
  }
  |> User.new_changeset()
  |> Repo.insert()

{:ok, picture} =
  %{
    title: "picture",
    location: %Geo.Point{coordinates: {80,40}, srid: 4326},
    expiration: Timex.now() |> Timex.shift([hours: 6]),
    picture_path: "/path/to/pictures",
    thumbnail_path: "path/to/thumbnails",
    md5: "abc123",
    user_id: user.id,
    category_id: category.id
  }
  |> Picture.new_changeset()
  |> Repo.insert()

IO.puts "Done"
