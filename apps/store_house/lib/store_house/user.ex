defmodule StoreHouse.User do
  use StoreHouse.Table, :user
  alias StoreHouse.Utils
  alias Geosnap.Encryption
  @min_pw_len 10

  @doc """
  Creates a new user row.
  """
  @spec new(String.t, String.t, String.t) :: {:ok, tuple} | {:error, term}
  def new(username, password, email) do
    with true <- Utils.valid_email?(email),
         length when length > @min_pw_len <- String.length(password)
    do
      row = user([
        key: username,
        email: email,
        hashed_password: Encryption.hash_password(password),
        inserted_at: Utils.timestamp(),
        updated_at: Utils.timestamp()
        ])
      {:ok, row}
    else
      false -> {:error, :invalid_email}
      length when is_integer(length) -> {:error, :password_too_short}
    end
  end

  @doc """
  Updates the `:verified_email` field on a user record.
  """
  @spec verify_email(tuple) :: {:ok, tuple} | {:error, term}
  def verify_email(user) do
    case user(user, :verified_email) do
      true -> {:error, :already_verified}
      false ->
        row = user(user, [
          verified_email: true,
          updated_at: Utils.timestamp()
        ])
        {:ok, row}
    end
  end

  @doc """
  Changes the email for a user record.
  Also resets the `:verified_email` field on said record.
  """
  @spec change_email(tuple, String.t) :: {:ok, tuple} | {:error, term}
  def change_email(user, new_email) do
    with old_email when old_email !== new_email <- user(user, :email),
         true <- Utils.valid_email?(new_email)
    do
      row = user(user, [
        email: new_email,
        verified_email: false,
        updated_at: Utils.timestamp()
      ])
      {:ok, row}
    else
      false -> {:error, :invalid_email}
      ^new_email -> {:error, :email_unchanged}
    end
  end

  @doc """
  Changes the password for a user record.
  """
  @spec change_password(tuple, String.t) :: {:ok, tuple} | {:error, term}
  def change_password(user, new_pw) do
    case String.length(new_pw) do
      length when length > @min_pw_len ->
        row = user(user, [
          hashed_password: Encryption.hash_password(new_pw),
          updated_at: Utils.timestamp()
        ])
        {:ok, row}
      _ -> {:error, :password_too_short}
    end
  end

  @doc """
  Changes the permissions for a user record.
  """
  @spec change_permissions(tuple, non_neg_integer) :: {:ok, tuple} | {:error, term}
  def change_permissions(user, new_perms) do
    cond do
      new_perms < 0 -> {:error, :invalid_permissions}
      new_perms === user(user, :permissions) -> {:error, :permissions_unchanged}
      is_integer(new_perms) ->
        row = user(user, [
          permissions: new_perms,
          updated_at: Utils.timestamp()
        ])
        {:ok, row}
      true -> {:error, :invalid_permissions}
    end
  end
end
