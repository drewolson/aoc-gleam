import aoc/util/re
import aoc/util/str
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/regex
import gleam/result
import gleam/string

fn int_map() -> Dict(String, String) {
  dict.from_list([
    #("zero", "0"),
    #("one", "1"),
    #("two", "2"),
    #("three", "3"),
    #("four", "4"),
    #("five", "5"),
    #("six", "6"),
    #("seven", "7"),
    #("eight", "8"),
    #("nine", "9"),
  ])
}

fn to_digit(line: String) -> Result(Int, Nil) {
  let re = re.make_regex("[0-9]")
  let f_match = regex.scan(re, line)
  let b_match = regex.scan(re, string.reverse(line))

  case f_match, b_match {
    [a, ..], [b, ..] -> int.parse(a.content <> b.content)
    _, _ -> Error(Nil)
  }
}

fn word_to_digit(str: String) -> String {
  int_map()
  |> dict.get(str)
  |> result.unwrap(str)
}

fn to_digit2(line: String) -> Result(Int, Nil) {
  let words =
    int_map()
    |> dict.keys()
    |> string.join("|")
  let re_f = re.make_regex("[0-9]|" <> words)
  let re_b = re.make_regex("[0-9]|" <> string.reverse(words))
  let f_match = regex.scan(re_f, line)
  let b_match = regex.scan(re_b, string.reverse(line))

  case f_match, b_match {
    [a, ..], [b, ..] -> {
      let f = word_to_digit(a.content)
      let l = b.content |> string.reverse |> word_to_digit
      int.parse(f <> l)
    }
    _, _ -> Error(Nil)
  }
}

pub fn part1(input: String) -> Int {
  input
  |> str.lines
  |> list.filter_map(to_digit)
  |> list.fold(0, fn(a, b) { a + b })
}

pub fn part2(input: String) -> Int {
  input
  |> str.lines
  |> list.filter_map(to_digit2)
  |> list.fold(0, fn(a, b) { a + b })
}
