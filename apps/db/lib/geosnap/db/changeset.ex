defmodule Geosnap.Db.Changeset do
  alias Ecto.Changeset
  import Changeset, only: [validate_change: 3]
  
  @doc false
  defmacro __using__(_) do
    quote do
      import Ecto.Changeset
      import unquote(__MODULE__)
    end
  end

  @doc """
  Validates the given field is an email address.
  """
  @spec validate_email(Changeset.t, atom) :: Changeset.t
  def validate_email(changeset, field) do
    validate_change(changeset, field, &do_validate_email/2)
  end

  def do_validate_email(field, email) do
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