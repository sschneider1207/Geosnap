defmodule Identity.Repo do
  @moduledoc false
  use Ecto.Repo, otp_app: :identity
  alias Identity.User

  def get_user_by_username(username) do
    get_by(User, username: username)
  end
end
