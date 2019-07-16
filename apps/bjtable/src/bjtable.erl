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
  B1 = btree:set(a, "a", B),
  B2 = btree:set(b, "b", B1),
  B3 = btree:set(a, "c", B2),
  io:format("~p~n", [B3]),
  io:format("~p~n", [btree:get(a, B3)]).
