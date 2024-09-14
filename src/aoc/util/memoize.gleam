import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/otp/actor.{type Next}

type MemoFn(a, b) =
  fn(fn(a) -> b, a) -> b

type Message(k, v) {
  Shutdown

  Insert(key: k, value: v)

  Get(key: k, reply_with: Subject(Result(v, Nil)))
}

fn handle_message(
  message: Message(k, v),
  cache: Dict(k, v),
) -> Next(Message(k, v), Dict(k, v)) {
  case message {
    Shutdown -> actor.Stop(process.Normal)
    Insert(key, value) -> {
      let new_state = dict.insert(cache, key, value)
      actor.continue(new_state)
    }
    Get(key, client) -> {
      cache |> dict.get(key) |> process.send(client, _)
      actor.continue(cache)
    }
  }
}

fn memoize_aux(cache: Subject(Message(a, b)), f: MemoFn(a, b)) -> fn(a) -> b {
  fn(a: a) -> b {
    case process.call(cache, Get(a, _), 10) {
      Ok(value) -> value
      Error(Nil) -> {
        let result = f(memoize_aux(cache, f), a)
        process.send(cache, Insert(a, result))
        result
      }
    }
  }
}

pub fn memoize(fun: MemoFn(a, b), f: fn(fn(a) -> b) -> c) -> c {
  let assert Ok(cache) = actor.start(dict.new(), handle_message)
  let result = f(memoize_aux(cache, fun))
  process.send(cache, Shutdown)
  result
}
