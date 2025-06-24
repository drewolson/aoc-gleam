import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder
import iv.{type Array}

fn bin_op(
  prog: Array(Int),
  pos: Int,
  op: fn(Int, Int) -> Int,
  f: fn(Array(Int)) -> Result(a, Nil),
) -> Result(a, Nil) {
  use ia <- result.try(iv.get(prog, pos + 1))
  use a <- result.try(iv.get(prog, ia))
  use ib <- result.try(iv.get(prog, pos + 2))
  use b <- result.try(iv.get(prog, ib))
  use r <- result.try(iv.get(prog, pos + 3))
  use new <- result.try(iv.set(prog, r, op(a, b)))

  f(new)
}

fn execute(prog: Array(Int), pos: Int) -> Result(Int, Nil) {
  use op <- result.try(iv.get(prog, pos))

  case op {
    1 -> {
      use new <- bin_op(prog, pos, fn(a, b) { a + b })

      execute(new, pos + 4)
    }
    2 -> {
      use new <- bin_op(prog, pos, fn(a, b) { a * b })

      execute(new, pos + 4)
    }
    99 -> iv.get(prog, 0)
    _ -> Error(Nil)
  }
}

pub fn part1(input: String) -> Int {
  input
  |> string.trim_end
  |> string.split(",")
  |> list.filter_map(int.parse)
  |> iv.from_list
  |> execute(0)
  |> result.unwrap(-1)
}

pub fn part2(input: String) -> Int {
  let prog =
    input
    |> string.trim_end
    |> string.split(",")
    |> list.filter_map(int.parse)
    |> iv.from_list

  let assert Ok(#(a, b)) =
    yielder.range(0, 99)
    |> yielder.flat_map(fn(a) {
      yielder.range(0, 99)
      |> yielder.map(fn(b) { #(a, b) })
    })
    |> yielder.find(fn(p) {
      let #(a, b) = p
      let new = prog |> iv.try_set(1, a) |> iv.try_set(2, b)

      execute(new, 0) == Ok(19_690_720)
    })

  100 * a + b
}
