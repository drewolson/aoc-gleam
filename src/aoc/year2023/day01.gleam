import aoc/util/li
import aoc/util/re
import aoc/util/str
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/regexp
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
  let re = re.from_string("[0-9]")
  let f_match = regexp.scan(re, line)
  let b_match = regexp.scan(re, string.reverse(line))

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
  let re_f = re.from_string("[0-9]|" <> words)
  let re_b = re.from_string("[0-9]|" <> string.reverse(words))
  let f_match = regexp.scan(re_f, line)
  let b_match = regexp.scan(re_b, string.reverse(line))

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
  |> li.sum
}

pub fn part2(input: String) -> Int {
  input
  |> str.lines
  |> list.filter_map(to_digit2)
  |> li.sum
}
