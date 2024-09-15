import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/otp/actor.{type Next}
import gleam/result

pub opaque type Hashtbl(k, v) {
  Hashtbl(Subject(Message(k, v)))
}

type Message(k, v) {
  Shutdown
  Insert(key: k, value: v)
  Get(key: k, reply_with: Subject(Result(v, Nil)))
}

fn handle_message(
  message: Message(k, v),
  dict: Dict(k, v),
) -> Next(Message(k, v), Dict(k, v)) {
  case message {
    Shutdown -> actor.Stop(process.Normal)
    Insert(key, value) -> dict |> dict.insert(key, value) |> actor.continue
    Get(key, client) -> {
      dict |> dict.get(key) |> process.send(client, _)
      actor.continue(dict)
    }
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
    Hashtbl(h) -> process.send(h, Insert(key, value))
  }
}

pub fn get(hashtbl: Hashtbl(k, v), key: k) -> Result(v, Nil) {
  case hashtbl {
    Hashtbl(h) -> process.call(h, Get(key, _), 10)
  }
}

pub fn new(f: fn(Hashtbl(a, b)) -> c) -> c {
  let assert Ok(hashtbl) = actor.start(dict.new(), handle_message)
  let result = f(Hashtbl(hashtbl))
  process.send(hashtbl, Shutdown)
  result
}
