defmodule Geosnap.Api.Router do
  use Geosnap.Api.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Geosnap.Api do
    pipe_through :api
  end
end
