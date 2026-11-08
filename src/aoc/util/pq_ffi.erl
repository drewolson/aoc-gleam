-module(pq_ffi).
-export([pop/1]).

pop(Q) ->
  case pqueue2:pout(Q) of
    {{value, Value, Priority}, NewQ} -> {ok, {Priority, Value, NewQ}};
    {empty, _} -> {error, nil}
  end.
