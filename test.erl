-module(test).

-export([start/0]).

start() ->
    io:format("~p ~p ~p~n", [
        time_compat:unique_integer(),
        time_compat:unique_integer(),
        time_compat:unique_integer()
      ]).
