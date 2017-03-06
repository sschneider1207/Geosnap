defmodule StoreHouse.Utils do
  @timestamp_precision :microsecond

  @spec timestamp() :: integer
  def timestamp do
    :os.system_time(@timestamp_precision)
  end

  @spec timestamp_to_datetime(integer) :: DateTime.t
  def timestamp_to_datetime(timestamp) do
    DateTime.from_unix!(timestamp, @timestamp_precision)
  end

  @spec new_key() :: String.t
  def new_key do
    UUID.uuid4(:hex)
  end

  @spec valid_email?(String.t) :: boolean
  def valid_email?(email) do
    valid_email?(email, false, false, false, false, false, false)
  end

  defp valid_email?(
    <<?\s :: utf8, rem :: binary>>,
    amp,
    _spaces,
    text_before,
    text_after,
    dot_after,
    error
  ) do
    valid_email?(rem, amp, true, text_before, text_after, dot_after, error)
  end
  defp valid_email?(
    <<?, :: utf8, rem :: binary>>,
    amp,
    _spaces,
    text_before,
    text_after,
    dot_after,
    error
  ) do
    valid_email?(rem, amp, true, text_before, text_after, dot_after, error)
  end
  defp valid_email?(
    <<?@ :: utf8, rem :: binary>>,
    amp = true,
    spaces,
    text_before,
    text_after,
    dot_after,
    _error
  ) do
    valid_email?(rem, amp, spaces, text_before, text_after, dot_after, true)
  end
  defp valid_email?(
    <<?@ :: utf8, rem :: binary>>,
    _amp,
    spaces,
    text_before,
    text_after,
    dot_after,
    error
  ) do
    valid_email?(rem, true, spaces, text_before, text_after, dot_after, error)
  end
  defp valid_email?(
    <<_ :: utf8, rem :: binary>>,
    amp = false,
    spaces,
    _text_before,
    text_after,
    dot_after,
    error
  ) do
    valid_email?(rem, amp, spaces, true, text_after, dot_after, error)
  end
  defp valid_email?(
    <<?. :: utf8, rem :: binary>>,
    amp,
    spaces,
    text_before,
    text_after,
    _dot_after,
    error
  ) do
    valid_email?(rem, amp, spaces, text_before, text_after, true, error)
  end
  defp valid_email?(
    <<_ :: utf8, rem :: binary>>,
    amp,
    spaces,
    text_before,
    _text_after,
    dot_after,
    error
  ) do
    valid_email?(rem, amp, spaces, text_before, true, dot_after, error)
  end
  defp valid_email?(<<>>, amp, spaces, text_before, text_after, dot_after, error) do
    (spaces or
    (not amp) or
    (not text_after) or
    (not text_before) or
    (not dot_after) or
    error) === false
  end
end
