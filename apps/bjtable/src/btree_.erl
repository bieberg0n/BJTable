%%%-------------------------------------------------------------------
%%% @author bj
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 七月 2019 下午3:20
%%%-------------------------------------------------------------------
-module(btree_).
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
  Self = self(),
  spawn(fun () -> nodes_loop(Nodes, Self) end).


set(BTree, K, V) ->
  BTree ! {set, K, V, self()}.
%%  receive ok -> ok end.


get(BTree, K) ->
  BTree ! {get, K, self()},
  receive V -> V end.


print(BTree) ->
  BTree ! print.


nodes_loop(Nodes, Father) ->
  receive
    {set, Key, Value, From} ->
      io:format("set: ~p ~p~n", [Key, Value]),
      New_nodes = nodes_set(Key, Value, Nodes, From),
      case New_nodes of
        destroy ->
          ok;
        _ ->
          io:format("new nodes: ~p~n", [New_nodes])
%%          From ! ok
      end,
      nodes_loop(New_nodes, Father);

%%    {set, Key, Value} ->
%%      New_nodes = nodes_set(Key, Value, Nodes),
%%      nodes_loop(New_nodes, Father);

    {insert, Node} ->
      New_nodes = nodes_insert(Node, Nodes),
      #node{left = L, right = R} = Node,
      L ! {new_father, self()},
      R ! {new_father, self()},
      nodes_loop(New_nodes, Father);

    {new_father, F} ->
      nodes_loop(Nodes, F);

    {get, Key, From} ->
      nodes_get(Key, Nodes, From),
      nodes_loop(Nodes, Father);

    print ->
      io:format("I'm ~p, Father is ~p, ~p~n", [self(), Father, Nodes]),
      nodes_print(Nodes),
      nodes_loop(Nodes, Father);

    {up, Node} ->
      io:format("up ~p, I'm ~p, Father is ~p~n", [Node, self(), Father]),
      case Father of
        empty ->
          nodes_loop([Node], Father);
        _ ->
          Father ! {insert, Node}
      end;

    UnknownMsg ->
      io:format("error msg:~p~n", [UnknownMsg]),
      nodes_loop(Nodes, Father)
  end.


nodes_print([]) ->
  ok;

nodes_print([H|T]) ->
  #node{left = L, right = R} = H,
  if
    L =/= empty ->
      L ! print;
    true ->
      ok
  end,
  if
    R =/= empty ->
      R ! print;
    true ->
      ok
  end,
  nodes_print(T).


nodes_set(Key, Value, [H|[]], Result, From) ->
  #node{key=K, left=L, right=R} = H,
  if
    Key == K ->
      io:format("key == k, ~p ~p~n", [Key, K]),
      lists:reverse([H#node{key=Key, value=Value} | Result]);
    Key < K ->
      case L of
        empty ->
          io:format("left is empty, check..."),
          check(lists:reverse(Result) ++ [#node{key=Key, value=Value}, H]);
        _ ->
          io:format("send to left~n"),
          L ! {set, Key, Value, From},
          lists:reverse([H|Result])
      end;
    Key > K ->
      case R of
        empty ->
          io:format("right is empty, check...~n"),
          check(lists:reverse(Result) ++ [H, #node{key=Key, value=Value}]);
        _ ->
          io:format("send to right: ~p~n", [R]),
          R ! {set, Key, Value, From},
          lists:reverse([H|Result])
      end
  end;

nodes_set(Key, Value, [H|T], Result, From) ->
  #node{key=K, left=L} = H,
  if
    Key == K ->
      io:format("key == k, ~p ~p~n", [Key, K]),
      lists:reverse(Result) ++ [H#node{key=Key, value=Value} | T];
    Key < K ->
      case L of
        empty ->
          io:format("left is empty, check...~n"),
          check(lists:reverse(Result) ++ [#node{key=Key, value=Value}, H | T]);
        _ ->
          L ! {set, Key, Value, From},
          io:format("send to right~n"),
          lists:reverse(Result) ++ [H|T]
      end;
    true ->
      nodes_set(Key, Value, T, [H|Result], From)
  end.


nodes_set(Key, Value, [], _) ->
  [#node{key=Key, value=Value}];

nodes_set(Key, Value, Nodes, From) ->
  nodes_set(Key, Value, Nodes, [], From).


nodes_insert(Node, Nodes) ->
  nodes_insert(Node, Nodes, []).


nodes_insert(Node, [], R) ->
  check(lists:reverse([Node| R]));

nodes_insert(Node, [H|T], R) ->
  if
    Node#node.key < H#node.key ->
      check(lists:reverse(R) ++ [Node, H | T]);
%%      check(New_nodes),
%%      New_nodes;
    true ->
      nodes_insert(Node, T, [H|R])
  end.


check(Nodes) ->
  io:format("check nodes are:~p~n", [Nodes]),
  if
    length(Nodes) > 2 ->
      io:format("split~n"),
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
%%  Left ! print,
%%  Right ! print,
  Node = H#node{left=Left, right=Right},
  io:format("send self up, I'm ~p~n", [self()]),
  self() ! {up, Node},
  destroy;

split([H|T], R, X, N) ->
  split(T, [H|R], X+1, N).


nodes_get(Key, [H|[]], From) ->
  #node{key=K, value=V, left=L, right=R} = H,
  if
    Key == K ->
      From ! V;
    Key < K ->
      L ! {get, Key, From};
    Key > K ->
      case R of
        empty ->
          From ! null;
        _ ->
          R ! {get, Key, From}
      end
  end;

nodes_get(Key, [H|T], From) ->
%%  K = H#node.key,
  #node{key = K, value = V, left = L} = H,
  if
    K == Key ->
      From ! V;
    K < Key ->
      case L of
        empty ->
          From ! null;
        _ ->
          L ! {get, Key, From}
      end;
    true ->
      nodes_get(Key, T, From)
  end.
