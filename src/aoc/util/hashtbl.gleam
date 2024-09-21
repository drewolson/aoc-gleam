import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/option.{type Option}
import gleam/otp/actor.{type Next}
import gleam/result

pub opaque type Hashtbl(k, v) {
  Hashtbl(Int, Subject(Message(k, v)))
}

type Message(k, v) {
  Shutdown
  Delete(key: k)
  Get(key: k, reply_with: Subject(Result(v, Nil)))
  Insert(key: k, value: v)
  MapValues(f: fn(k, v) -> v)
  Size(reply_with: Subject(Int))
  ToList(reply_with: Subject(List(#(k, v))))
  Upsert(key: k, f: fn(Option(v)) -> v)
}

fn handle_message(
  message: Message(k, v),
  dict: Dict(k, v),
) -> Next(Message(k, v), Dict(k, v)) {
  case message {
    Shutdown -> actor.Stop(process.Normal)
    Delete(key) -> dict |> dict.delete(key) |> actor.continue
    Get(key, client) -> {
      dict |> dict.get(key) |> process.send(client, _)
      actor.continue(dict)
    }
    Insert(key, value) -> dict |> dict.insert(key, value) |> actor.continue
    MapValues(f) -> dict |> dict.map_values(f) |> actor.continue
    Size(client) -> {
      dict |> dict.size |> process.send(client, _)
      actor.continue(dict)
    }
    ToList(client) -> {
      dict |> dict.to_list |> process.send(client, _)
      actor.continue(dict)
    }
    Upsert(key, f) -> dict |> dict.upsert(key, f) |> actor.continue
  }
}

pub fn get_or(hashtbl: Hashtbl(k, v), key: k, f: fn() -> v) -> v {
  hashtbl
  |> get(key)
  |> result.lazy_unwrap(fn() {
    let value = f()
    insert(hashtbl, key, value)
    value
  })
}

pub fn insert(hashtbl: Hashtbl(k, v), key: k, value: v) -> Nil {
  case hashtbl {
    Hashtbl(_, h) -> process.send(h, Insert(key, value))
  }
}

pub fn get(hashtbl: Hashtbl(k, v), key: k) -> Result(v, Nil) {
  case hashtbl {
    Hashtbl(t, h) -> process.call(h, Get(key, _), t)
  }
}

pub fn delete(hashtbl: Hashtbl(k, v), key: k) -> Nil {
  case hashtbl {
    Hashtbl(_, h) -> process.send(h, Delete(key))
  }
}

pub fn to_list(hashtbl: Hashtbl(k, v)) -> List(#(k, v)) {
  case hashtbl {
    Hashtbl(t, h) -> process.call(h, ToList, t)
  }
}

pub fn size(hashtbl: Hashtbl(k, v)) -> Int {
  case hashtbl {
    Hashtbl(t, h) -> process.call(h, Size, t)
  }
}

pub fn upsert(hashtbl: Hashtbl(k, v), key: k, f: fn(Option(v)) -> v) -> Nil {
  case hashtbl {
    Hashtbl(_, h) -> process.send(h, Upsert(key, f))
  }
}

pub fn map_values(hashtbl: Hashtbl(k, v), f: fn(k, v) -> v) -> Nil {
  case hashtbl {
    Hashtbl(_, h) -> process.send(h, MapValues(f))
  }
}

pub fn from_list_with_timeout(
  list: List(#(k, v)),
  timeout: Int,
  f: fn(Hashtbl(k, v)) -> a,
) -> a {
  let assert Ok(hashtbl) = actor.start(dict.from_list(list), handle_message)
  let result = f(Hashtbl(timeout, hashtbl))
  process.send(hashtbl, Shutdown)
  result
}

pub fn from_list(list: List(#(k, v)), f: fn(Hashtbl(k, v)) -> a) -> a {
  from_list_with_timeout(list, 10, f)
}

pub fn new_with_timeout(timeout: Int, f: fn(Hashtbl(a, b)) -> c) -> c {
  from_list_with_timeout([], timeout, f)
}

pub fn new(f: fn(Hashtbl(k, v)) -> a) -> a {
  new_with_timeout(10, f)
}
