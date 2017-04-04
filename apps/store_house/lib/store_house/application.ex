defmodule StoreHouse.Application do
  use StoreHouse.Table, :application
  alias StoreHouse.Utils

  @doc """
  Creates a new application record based on a name and email.
  """
  @spec new(String.t, String.t) :: {:ok, tuple} | {:error, term}
  def new(name, email) do
    case Utils.valid_email?(email) do
      false -> {:error, :invalid_email}
      true ->
        row = application([
          key: Utils.new_key(),
          name: name,
          email: email,
          permissions: 0,
          inserted_at: Utils.timestamp(),
          updated_at: Utils.timestamp()
        ])
        {:ok, row}
    end
  end

  @doc """
  Updates the `:verified_email` field on an application record.
  """
  @spec verify_email(tuple) :: {:ok, tuple} | {:error, term}
  def verify_email(app) do
    case application(app, :verified_email) do
      true -> {:error, :already_verified}
      false ->
        row = application(app, [
          verified_email: true,
          updated_at: Utils.timestamp()
        ])
        {:ok, row}
    end
  end

  @doc """
  Changes the email for an application record.
  Also resets the `:verified_email` field on said record.
  """
  @spec change_email(tuple, String.t) :: {:ok, tuple} | {:error, term}
  def change_email(app, new_email) do
    with old_email when old_email !== new_email <- application(app, :email),
         true <- Utils.valid_email?(new_email)
    do
      row = application(app, [
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
end
