defmodule Geosnap.Db.Changeset do
  alias Ecto.Changeset
  import Changeset

  @doc false
  defmacro __using__(_) do
    quote do
      import Ecto.Changeset
      import unquote(__MODULE__)
    end
  end

  @doc """
  Hashes the password field in the changeset and puts it in the `hashed_password` field.
  """
  @spec hash_password_field(Changeset.t) :: Changeset.t
  def hash_password_field(changeset) do
    case get_change(changeset, :password) do
      nil ->
        changeset
      password ->
        hashed_password = Geosnap.Encryption.hash_password(password)
        put_change(changeset, :hashed_password, hashed_password)
    end
  end

  @doc """
  Validates the given field is a valid EPSG 4326 coordinate pair.
  """
  @spec validate_lnglat(Changeset.t, atom) :: Changeset.t
  def validate_lnglat(changeset, field) do
    validate_change(changeset, field, &do_validate_lnglat/2)
  end

  defp do_validate_lnglat(field, point) do
    %{coordinates: {lng, lat}, srid: srid} = point
    cond do
      lng < -180.0 or lng > 180.0 -> [{field, "has an invalid longitude value"}]
      lat < -90.0 or lat > 90.0 -> [{field, "has an invalid latitude value"}]
      srid != 4326 -> [{field, "is not an EPSG 4326 coordinate pair"}]
      true -> []
    end
  end

  @doc """
  Validates the `expiration` field to be between a set interval.
  """
  @spec validate_expiration(Changeset.t) :: Changeset.t
  def validate_expiration(changeset) do
    validate_change(changeset, :expiration, &do_validate_expiration/2)
  end

  defp do_validate_expiration(field, expiration) do
    cur_hour =
      Timex.now()
      |> Timex.set([minute: 0, second: 0, microsecond: {0, 0}])
    min = Timex.shift(cur_hour, [hours: 1])
    max = Timex.shift(cur_hour, [days: 1])
    case Timex.between?(expiration, min, max) do
      true -> []
      false -> [{field, "is not a valid expiration datetime"}]
    end
  end

  @doc """
  Validates the given field is an email address.
  """
  @spec validate_email(Changeset.t, atom) :: Changeset.t
  def validate_email(changeset, field) do
    validate_change(changeset, field, &do_validate_email/2)
  end

  defp do_validate_email(field, email) do
    case check_email(email) do
      false -> []
      true -> [{field, "is not a valid email address with no spaces or commas"}]
    end
  end

  defp check_email(email) do
    check_email(email, false, false, false, false, false, false)
  end

  defp check_email(
    <<?\s :: utf8, rem :: binary>>,
    amp,
    _spaces,
    text_before,
    text_after,
    dot_after,
    error
  ) do
    check_email(rem, amp, true, text_before, text_after, dot_after, error)
  end
  defp check_email(
    <<?, :: utf8, rem :: binary>>,
    amp,
    _spaces,
    text_before,
    text_after,
    dot_after,
    error
  ) do
    check_email(rem, amp, true, text_before, text_after, dot_after, error)
  end
  defp check_email(
    <<?@ :: utf8, rem :: binary>>,
    amp = true,
    spaces,
    text_before,
    text_after,
    dot_after,
    _error
  ) do
    check_email(rem, amp, spaces, text_before, text_after, dot_after, true)
  end
  defp check_email(
    <<?@ :: utf8, rem :: binary>>,
    _amp,
    spaces,
    text_before,
    text_after,
    dot_after,
    error
  ) do
    check_email(rem, true, spaces, text_before, text_after, dot_after, error)
  end
  defp check_email(
    <<_ :: utf8, rem :: binary>>,
    amp = false,
    spaces,
    _text_before,
    text_after,
    dot_after,
    error
  ) do
    check_email(rem, amp, spaces, true, text_after, dot_after, error)
  end
  defp check_email(
    <<?. :: utf8, rem :: binary>>,
    amp,
    spaces,
    text_before,
    text_after,
    _dot_after,
    error
  ) do
    check_email(rem, amp, spaces, text_before, text_after, true, error)
  end
  defp check_email(
    <<_ :: utf8, rem :: binary>>,
    amp,
    spaces,
    text_before,
    _text_after,
    dot_after,
    error
  ) do
    check_email(rem, amp, spaces, text_before, true, dot_after, error)
  end
  defp check_email(<<>>, amp, spaces, text_before, text_after, dot_after, error) do
    spaces or
    (not amp) or
    (not text_after) or
    (not text_before) or
    (not dot_after) or
    error
  end
end
