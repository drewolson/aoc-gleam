import aoc/util/hashtbl
import gleam/option.{None, Some}
import gleeunit/should

pub fn upsert_test() {
  use h <- hashtbl.from_list([#("a", 1)])

  let f = fn(o) {
    case o {
      Some(v) -> v + 1
      None -> 0
    }
  }

  hashtbl.upsert(h, "a", f)
  hashtbl.upsert(h, "b", f)

  h
  |> hashtbl.get("a")
  |> should.equal(Ok(2))

  h
  |> hashtbl.get("b")
  |> should.equal(Ok(0))

  h
  |> hashtbl.get("c")
  |> should.equal(Error(Nil))
}
