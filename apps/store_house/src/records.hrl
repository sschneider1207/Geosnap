-record(api_key, {key :: binary(),
                  application_key :: binary(),
                  inserted_at :: integer(),
                  updated_at :: integer()}).

-record(application, {key :: binary(),
                      name :: binary(),
                      email :: binary(),
                      verified_email = false :: boolean(),
                      inserted_at :: integer(),
                      updated_at :: integer()}).

-record(category, {key :: atom(),
                   color :: binary() | {integer(), integer(), integer()},
                   inserted_at :: integer(),
                   updated_at :: integer()}).

-record(comment, {key :: binary(),
                  text :: binary(),
                  depth = 0 :: integer(),
                  user_key :: binary(),
                  picture_key :: binary(),
                  parent_key :: binary() | undefined,
                  inserted_at :: integer(),
                  updated_at :: integer()}).

-record(picture, {key :: binary(),
                  title :: binary(),
                  location = {undefined, undefined} :: {integer(), integer()},
                  picture_path :: binary(),
                  thumbnail_path :: binary(),
                  hash :: binary(),
                  user_key :: binary(),
                  category_key :: binary(),
                  application_key :: binary(),
                  inserted_at :: integer(),
                  updated_at :: integer()}).

-record(score, {key :: binary(),
                value = 0 :: integer()}).

-record(user, {key :: binary(),
               hashed_password :: binary(),
               email :: binary(),
               verified_email = false :: binary(),
               permissions = 0 :: integer(),
               inserted_at :: integer(),
               updated_at :: integer()}).

-record(vote, {key = {undefined, undefined} :: {binary(), binary()},
               value :: integer(),
               inserted_at :: integer(),
               updated_at :: integer()}).
