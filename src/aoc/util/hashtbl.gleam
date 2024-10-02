import carpenter/table.{type Set}
import gleam/option.{type Option}
import gleam/result
import youid/uuid

pub opaque type Hashtbl(k, v) {
  Hashtbl(table: Set(k, v))
}

pub fn insert(hashtbl: Hashtbl(k, v), key: k, value: v) -> Nil {
  table.insert(hashtbl.table, [#(key, value)])
}

pub fn insert_all(hashtbl: Hashtbl(k, v), list: List(#(k, v))) -> Nil {
  table.insert(hashtbl.table, list)
}

pub fn get(hashtbl: Hashtbl(k, v), key: k) -> Result(v, Nil) {
  case table.lookup(hashtbl.table, key) {
    [] -> Error(Nil)
    [#(_, v), ..] -> Ok(v)
  }
}

pub fn delete(hashtbl: Hashtbl(k, v), key: k) -> Nil {
  table.delete(hashtbl.table, key)
}

pub fn upsert(hashtbl: Hashtbl(k, v), key: k, f: fn(Option(v)) -> v) -> Nil {
  hashtbl
  |> get(key)
  |> option.from_result
  |> f
  |> insert(hashtbl, key, _)
}

pub fn get_or_lazy(hashtbl: Hashtbl(k, v), key: k, f: fn() -> v) -> v {
  hashtbl
  |> get(key)
  |> result.lazy_unwrap(fn() {
    let value = f()
    insert(hashtbl, key, value)
    value
  })
}

pub fn from_list(list: List(#(k, v)), f: fn(Hashtbl(k, v)) -> a) -> a {
  let name = uuid.v4() |> uuid.to_string
  let assert Ok(hashtbl) =
    table.build(name)
    |> table.set
    |> result.map(Hashtbl)
  insert_all(hashtbl, list)
  let result = f(hashtbl)
  table.drop(hashtbl.table)
  result
}

pub fn new(f: fn(Hashtbl(k, v)) -> a) -> a {
  from_list([], f)
}
