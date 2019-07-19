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
  btree:set(B, a, "a"),
  btree:print(B),
  btree:set(B, b, "b"),
  btree:print(B),
  btree:set(B, c, "c"),
  btree:set(B, a, "c"),
  io:format("~p~n", [btree:get(B, b)]),
  io:format("~p~n", [btree:get(B, a)]),
  btree:print(B).
%%  receive _ -> ok end.
