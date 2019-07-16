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
  get/2
]).

new() ->
  [].

set(K, V, [], R) ->
  [{K, V} | lists:reverse(R)];
set(Key, Value, [H|T], R) ->
  case H of
    {Key, _} ->
      lists:reverse(R) ++ [{Key, Value} | T];
    _ ->
      set(Key, Value, T, [H|R])
  end.

set(Key, Value, []) ->
  [{Key, Value}];
set(Key, Value, B) ->
  set(Key, Value, B, []).

get(Key, BTree) ->
  R = [X || {Key, X} <- BTree],
  case length(R) of
    0 ->
      null;
    _ ->
      [H|_] = R,
      H
  end.