%%%-------------------------------------------------------------------
%%% @author bj
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 七月 2019 下午12:34
%%%-------------------------------------------------------------------
-module(bjtable).
-author("bj").

%% API
-export([
  main/0
]).

main() ->
  B = btree:new(),
  btree:set(B, {a, "a"}),
  btree:set(B, {b, "b"}),
  btree:set(B, {e, "e"}),
  btree:set(B, {c, "c"}),
%%  btree:set(B, a, "c"),
  btree:set(B, {d, "d"}),
%%  timer:sleep(100),
%%  btree:print(B),

%%  btree:set(B, f, "f"),
%%  btree:set(B, g, "g"),
%%  btree:set(B, h, "h"),
%%  btree:set(B, i, "i"),
%%  timer:sleep(100),
  btree:print(B).
%%  io:format("~p~n", [btree:get(B, g)]),
%%  io:format("~p~n", [btree:get(B, h)]),
%%  io:format("~p~n", [btree:get(B, i)]).
%%  receive _ -> ok end.
