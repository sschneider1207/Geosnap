-module(qlc_queries).
-include_lib("stdlib/include/qlc.hrl").
-include("records.hrl").


-export([application_by_name/1]).

application_by_name(Name) ->
  qlc:q([A || A <- mnesia:table(application),
    A#application.name == Name]).
