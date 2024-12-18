import aoc/util/parser.{type Parser}
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder.{type Yielder, Next}
import party

type Vm {
  Vm(a: Int, b: Int, c: Int, pos: Int, prog: Dict(Int, Int))
}

fn reg_p(name: String) -> Parser(Int) {
  use <- party.drop(party.string("Register " <> name <> ": "))
  use v <- party.do(parser.int())
  use <- party.drop(party.string("\n"))
  party.return(v)
}

fn vm_p() -> Parser(Vm) {
  use a <- party.do(reg_p("A"))
  use b <- party.do(reg_p("B"))
  use c <- party.do(reg_p("C"))
  use <- party.drop(party.string("\nProgram: "))
  use ops <- party.map(party.sep1(parser.int(), party.string(",")))
  let prog = ops |> list.index_map(fn(o, i) { #(i, o) }) |> dict.from_list
  Vm(a:, b:, c:, pos: 0, prog:)
}

fn combo(vm: Vm, i: Int) -> Int {
  case i {
    4 -> vm.a
    5 -> vm.b
    6 -> vm.c
    i -> i
  }
}

fn pow(a: Int, b: Int) -> Int {
  a
  |> int.power(int.to_float(b))
  |> result.unwrap(0.0)
  |> float.truncate
}

fn opcode(vm: Vm) -> Result(Int, Nil) {
  dict.get(vm.prog, vm.pos)
}

fn operand(vm: Vm) -> Result(Int, Nil) {
  dict.get(vm.prog, vm.pos + 1)
}

fn dv(vm: Vm) -> Result(Int, Nil) {
  use arg <- result.map(operand(vm))
  vm.a / pow(2, combo(vm, arg))
}

fn mod(vm: Vm) -> Result(Int, Nil) {
  use arg <- result.try(operand(vm))
  arg |> combo(vm, _) |> int.modulo(8)
}

fn run(vm: Vm, output: List(Int)) -> List(Int) {
  let res = {
    use op <- result.try(opcode(vm))
    case op {
      0 -> {
        use res <- result.map(dv(vm))
        #(Vm(..vm, a: res, pos: vm.pos + 2), output)
      }
      1 -> {
        use arg <- result.map(operand(vm))
        let res = int.bitwise_exclusive_or(vm.b, arg)
        #(Vm(..vm, b: res, pos: vm.pos + 2), output)
      }
      2 -> {
        use res <- result.map(mod(vm))
        #(Vm(..vm, b: res, pos: vm.pos + 2), output)
      }
      3 -> {
        case vm.a == 0 {
          True -> Ok(#(Vm(..vm, pos: vm.pos + 2), output))
          False -> {
            use arg <- result.map(operand(vm))
            #(Vm(..vm, pos: arg), output)
          }
        }
      }
      4 -> {
        let res = int.bitwise_exclusive_or(vm.b, vm.c)
        Ok(#(Vm(..vm, b: res, pos: vm.pos + 2), output))
      }
      5 -> {
        use res <- result.map(mod(vm))
        #(Vm(..vm, pos: vm.pos + 2), [res, ..output])
      }
      6 -> {
        use res <- result.map(dv(vm))
        #(Vm(..vm, b: res, pos: vm.pos + 2), output)
      }
      _ -> {
        use res <- result.map(dv(vm))
        #(Vm(..vm, c: res, pos: vm.pos + 2), output)
      }
    }
  }

  case res {
    Error(_) -> list.reverse(output)
    Ok(#(vm, output)) -> run(vm, output)
  }
}

fn ints(start: Int) -> Yielder(Int) {
  yielder.unfold(start, fn(n) { Next(n, n + 1) })
}

fn search(vm: Vm, n: Int, d: Int, goal: List(Int)) -> Int {
  case d > list.length(goal) {
    True -> n / 8
    False -> {
      let cur_goal = list.take(goal, d)
      let assert Ok(next) =
        n
        |> ints
        |> yielder.find(fn(i) {
          let actual =
            Vm(..vm, a: i)
            |> run([])
            |> list.reverse
            |> list.take(d)

          actual == cur_goal
        })

      search(vm, next * 8, d + 1, goal)
    }
  }
}

pub fn part1(input: String) -> String {
  input
  |> parser.go(vm_p())
  |> run([])
  |> list.map(int.to_string)
  |> string.join(",")
}

pub fn part2(input: String) -> Int {
  let vm = parser.go(input, vm_p())

  let goal =
    vm.prog
    |> dict.to_list
    |> list.sort(fn(a, b) { int.compare(b.0, a.0) })
    |> list.map(fn(p) { p.1 })

  search(vm, 0, 1, goal)
}
