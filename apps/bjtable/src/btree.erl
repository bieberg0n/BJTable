%%%-------------------------------------------------------------------
%%% @author bj
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 七月 2019 下午3:20
%%%-------------------------------------------------------------------
-module(btree).
-author("bj").

%% API
-export([
  new/0,
  set/3,
  get/2,
  print/1
]).

-record(node, {
  key,
  value,
  left = empty,
  right = empty
}).


new() ->
  spawn(fun () -> nodes_loop([], empty) end).


new(Nodes) ->
  spawn(fun () -> nodes_loop(Nodes, empty) end).


set(BTree, K, V) ->
  BTree ! {set, K, V}.


get(BTree, K) ->
  BTree ! {get, K, self()},
  receive V -> V end.


print(BTree) ->
  BTree ! print.


nodes_loop(Nodes, Father) ->
  receive
    {set, Key, Value} ->
      New_nodes = nodes_set(Key, Value, Nodes),
      nodes_loop(New_nodes, Father);

    {insert, Node} ->
      New_nodes = nodes_insert(Node, Nodes),
      nodes_loop(New_nodes, Father);

    {get, Key, From} ->
      From ! nodes_get(Key, Nodes),
      nodes_loop(Nodes, Father);

    print ->
      io:format("~p~n", [Nodes]),
      nodes_loop(Nodes, Father);

    {up, Node} ->
      io:format("up ~p~n", [Node]),
      case Father of
        empty ->
          nodes_loop([Node], Father);
        _ ->
          Father ! {insert, Node}
      end
  end.


%%nodes_set(K, V, [], R) ->
%%  [#node{key=K, value=V} | lists:reverse(R)];
nodes_set(K, V, [H|[]], R) ->
  case H#node.right of
    empty ->
      check(lists:reverse(R) ++ [H, #node{key=K, value=V}]);
    Right ->
      Right ! {set, K, V},
      lists:reverse([H|R])
  end;

nodes_set(Key, Value, [H|T], Result) ->
  #node{key=K, left=L} = H,
  if
    Key == K ->
      lists:reverse(Result) ++ [H#node{key=Key, value=Value} | T];
    Key < K ->
      case L of
        empty ->
%%          New_nodes = lists:reverse(Result) ++ [#node{key=Key, value=Value}, H | T],
%%          check(New_nodes),
%%          New_nodes;
          check(lists:reverse(Result) ++ [#node{key=Key, value=Value}, H | T]);
        {_, false} ->
          L ! {set, Key, Value}
      end;
    true ->
      nodes_set(Key, Value, T, [H|Result])
  end.


nodes_set(Key, Value, []) ->
  [#node{key=Key, value=Value}];

nodes_set(Key, Value, Nodes) ->
  nodes_set(Key, Value, Nodes, []).


nodes_insert(Node, Nodes) ->
  nodes_insert(Node, Nodes, []).


nodes_insert(Node, [H|T], R) ->
  if
    Node#node.key < H#node.key ->
      New_nodes = lists:reverse(R) ++ [Node, H | T],
      check(New_nodes),
      New_nodes;
    true ->
      nodes_insert(Node, T, [H|R])
  end.


check(Nodes) ->
  if
    length(Nodes) > 2 ->
      split(Nodes);
    true ->
      Nodes
  end.


split(Nodes) ->
  N = length(Nodes) div 2,
  split(Nodes, [], 0, N).


split([H|T], R, N, N) ->
  Left = new(lists:reverse(R)),
  Right = new(T),
  Node = H#node{left=Left, right=Right},
  self() ! {up, Node},
  lists:reverse(R) ++ [H|T];

split([H|T], R, X, N) ->
  split(T, [H|R], X+1, N).


nodes_get(_, []) ->
  null;

nodes_get(Key, [H|T]) ->
  case H#node.key of
    Key ->
      H#node.value;
    _ ->
      nodes_get(Key, T)
  end.
