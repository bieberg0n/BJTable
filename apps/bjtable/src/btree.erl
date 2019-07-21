%%%-------------------------------------------------------------------
%%% @author bj
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. 7月 2019 17:02
%%%-------------------------------------------------------------------
-module(btree).
-author("bj").

%% API
-export([
  new/0,
  set/2,
  print/1
]).

-import(lists, [reverse/1]).

new() ->
  spawn(fun () -> nodes_loop([]) end).


set(B, {K, V}) ->
  B ! {self(), set, {K, V}},
  receive ok -> ok end.


print(B) ->
  B ! print.


nodes_loop(Nodes) ->
  receive
    {From, set, {K, V}} ->
      New_nodes = nodes_set({K, V}, Nodes),
      From ! ok,
      nodes_loop(New_nodes);

    print ->
      io:format("~p~n", [Nodes]);

    UnknownMsg ->
      io:format("error msg:~p~n", [UnknownMsg]),
      nodes_loop(Nodes)
  end.


nodes_set({Key, Value}, Nodes) ->
  nodes_set({Key, Value}, Nodes, []).


nodes_set({K, V}, [{K, _}|T], R) ->
  reverse(R) ++ [{K, V} | T];

nodes_set({Key, Val}, [{K, V}|T], R) when Key > K ->
  nodes_set({Key, Val}, T, [{K, V} | R]);

nodes_set({Key, Val}, [{K, V} | T], R) when Key < K ->
  reverse(R) ++ [{Key, Val}, {K, V} | T];

nodes_set(P, [], R) ->
  reverse([P | R]).
