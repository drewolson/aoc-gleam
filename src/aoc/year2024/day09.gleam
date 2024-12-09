import gleam/deque.{type Deque}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder.{type Yielder}

type Block {
  File(size: Int, content: Int)
  Free(size: Int)
}

fn compress(d: Deque(Block)) -> Yielder(#(Int, Int)) {
  case deque.pop_front(d) {
    Error(_) -> yielder.empty()
    Ok(#(File(size:, content:), d)) -> {
      use <- yielder.yield(#(size, content))
      compress(d)
    }
    Ok(#(Free(size: 0), d)) -> compress(d)
    Ok(#(Free(size: free), d)) -> {
      case deque.pop_back(d) {
        Error(_) -> yielder.empty()
        Ok(#(Free(_), d)) -> {
          d |> deque.push_front(Free(free)) |> compress
        }
        Ok(#(File(size:, content:), d)) if free >= size -> {
          use <- yielder.yield(#(size, content))
          d |> deque.push_front(Free(free - size)) |> compress
        }
        Ok(#(File(size:, content:), d)) -> {
          use <- yielder.yield(#(free, content))
          d |> deque.push_back(File(size - free, content)) |> compress
        }
      }
    }
  }
}

fn insert(d: Deque(Block), size: Int, content: Int) -> Result(Deque(Block), Nil) {
  use #(b, d) <- result.try(deque.pop_front(d))

  case b {
    Free(size: free) if free >= size -> {
      d
      |> deque.push_front(Free(free - size))
      |> deque.push_front(File(size, content))
      |> Ok
    }
    _ -> {
      use d <- result.map(insert(d, size, content))
      deque.push_front(d, b)
    }
  }
}

fn compress2(d: Deque(Block)) -> Deque(#(Int, Int)) {
  case deque.pop_back(d) {
    Error(_) -> deque.new()
    Ok(#(Free(0), d)) -> d |> compress2
    Ok(#(Free(size), d)) -> d |> compress2 |> deque.push_back(#(size, 0))
    Ok(#(File(size:, content:), d)) -> {
      case insert(d, size, content) {
        Ok(d) -> d |> compress2 |> deque.push_back(#(size, 0))
        Error(_) -> d |> compress2 |> deque.push_back(#(size, content))
      }
    }
  }
}

fn expand(blocks: Yielder(#(Int, Int))) -> Yielder(Int) {
  yielder.flat_map(blocks, fn(b) {
    let #(size, content) = b

    content
    |> yielder.single
    |> yielder.cycle
    |> yielder.take(size)
  })
}

fn checksum(blocks: Yielder(#(Int, Int))) -> Int {
  blocks
  |> expand
  |> yielder.index
  |> yielder.fold(0, fn(s, p) { s + { p.0 * p.1 } })
}

fn parse_blocks(str: String) -> Deque(Block) {
  str
  |> string.trim
  |> string.to_graphemes
  |> list.filter_map(int.parse)
  |> list.index_map(fn(n, i) {
    case int.is_even(i) {
      False -> Free(size: n)
      True -> File(size: n, content: i / 2)
    }
  })
  |> deque.from_list
}

pub fn part1(input: String) -> Int {
  input
  |> parse_blocks
  |> compress
  |> checksum
}

pub fn part2(input: String) -> Int {
  input
  |> parse_blocks
  |> compress2
  |> deque.to_list
  |> yielder.from_list
  |> checksum
}
