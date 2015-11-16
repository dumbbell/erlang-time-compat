-module(time_compat).

-export([unique_integer/0]).

-ifdef(OLD_API).
%% -------------------------------------------------------------------
%% Old Time API.
%% -------------------------------------------------------------------

-compile(nowarn_deprecated_function).

unique_integer() ->
    io:format("==> Old API~n"),
    {MS, S, US} = erlang:now(),
    (MS * 1000000 + S) * 1000000 + US.

-else.
-ifdef(NEW_API).
%% -------------------------------------------------------------------
%% New Time API.
%% -------------------------------------------------------------------

unique_integer() ->
    io:format("==> New API~n"),
    erlang:unique_integer().

-else.
%% -------------------------------------------------------------------
%% Loader.
%% -------------------------------------------------------------------

swap_module() ->
    global:set_lock({?MODULE, self()}, [node()]),
    io:format("[I] Delete old time_compat, external calls are blocked~n"),
    case code:delete(?MODULE) of
        true ->
            %% We could delete the current module (ie. this code trying
            %% to swap modules), so we are the first one to get there.
            do_swap_module(),
            true;
        false ->
            %% We can't delete the module because there is a copy of
            %% this module marked as "old", therefore the module was
            %% already swapped concurrently.
            io:format("[I] Already swapped~n"),
            %% FIXME: The code server logs an error report about this
            %% failed attempt.
            error_logger:error_msg("Please ignore the error report above "
              "about ~s which must be purged~n", [?MODULE]),
            false
    end,
    global:del_lock({?MODULE, self()}, [node()]).

do_swap_module() ->
    timer:sleep(1000), %% FIXME: Just to simulate a concurrent swap.
    io:format("[I] Determine filename~n"),
    Filename = case erlang:function_exported(erlang, unique_integer, 0) of
        true  -> code:where_is_file("time_compat_new.beam");
        false -> code:where_is_file("time_compat_old.beam")
    end,
    io:format("[I] Load binary from ~s~n", [Filename]),
    {ok, Binary} = file:read_file(Filename),
    io:format("[I] Load new time_compat~n"),
    {module, ?MODULE} = code:load_binary(?MODULE, Filename, Binary),
    io:format("[I] Done.~n"),
    ok.

unique_integer() ->
    swap_module(),
    erlang:spawn(fun() -> swap_module() end), %% FIXME: Just to simulate a concurrent swap.
    io:format("[I] Back in unique_integer()~n"),
    %% Call the newly loaded module variant.
    time_compat:unique_integer().

-endif.
-endif.
