use Mix.Config

config :geosnap_encryption,
  public_key: "BGBVQgFursnaEU/SYUwfdpzHr/81IiZ7f53FCO11o/RmOARdxjT/Awc6UiMy7p2o7WQF/qB+o5zJXxtG8J8UMy+hgP9EBfG6QKYiAR0LyVVHvLnHh4XqYgOiGP0FvYsRW6AYMO7I0thw/x/n7AVhyFc40cGE9g7XGVQ3LuLI9Qqy"

import_config "#{Mix.env}.secret.exs"
