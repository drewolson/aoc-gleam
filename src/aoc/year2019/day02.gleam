import aoc/year2019/int_code.{type IntCode, type Step, Continue, Stop}
import gleam/int
import gleam/list
import gleam/string
import gleam/yielder
import iv

fn execute(ic: IntCode, op: Int) -> Step(IntCode, Int) {
  case op {
    1 -> {
      let new = int_code.bin_op(ic, fn(a, b) { a + b })

      Continue(new)
    }
    2 -> {
      let new = int_code.bin_op(ic, fn(a, b) { a * b })

      Continue(new)
    }
    99 -> {
      let val = int_code.get_output(ic)

      Stop(val)
    }
    _ -> Continue(ic)
  }
}

pub fn part1(input: String) -> Int {
  input
  |> string.trim_end
  |> string.split(",")
  |> list.filter_map(int.parse)
  |> int_code.from_list
  |> int_code.execute(execute)
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
      let new =
        prog |> iv.try_set(1, a) |> iv.try_set(2, b) |> int_code.from_array

      int_code.execute(new, execute) == 19_690_720
    })

  100 * a + b
}
