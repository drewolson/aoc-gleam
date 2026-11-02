import aoc/util/li
import aoc/util/parser.{type Parser}
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import pears/chars
import pears/combinators

type Rule =
  #(Int, Int)

type Update =
  List(Int)

type Reqs =
  Dict(Int, Set(Int))

fn rule_p() -> Parser(Rule) {
  use a <- combinators.then(chars.natural())
  use <- parser.drop(chars.string("|"))
  use b <- combinators.map(chars.natural())
  #(a, b)
}

fn rules_p() -> Parser(List(Rule)) {
  combinators.sep_by1(rule_p(), chars.string("\n"))
}

fn update_p() -> Parser(Update) {
  combinators.sep_by1(chars.natural(), chars.string(","))
}

fn updates_p() -> Parser(List(Update)) {
  combinators.sep_by1(update_p(), chars.string("\n"))
}

fn input_p() -> Parser(#(List(Rule), List(Update))) {
  use rules <- combinators.then(rules_p())
  use <- parser.drop(chars.string("\n\n"))
  use updates <- combinators.map(updates_p())
  #(rules, updates)
}

fn build_reqs(rules: List(Rule)) -> Reqs {
  list.fold(rules, dict.new(), fn(reqs, rule) {
    let #(a, b) = rule
    dict.upsert(reqs, b, fn(opt) {
      case opt {
        None -> set.new() |> set.insert(a)
        Some(s) -> set.insert(s, a)
      }
    })
  })
}

fn valid(reqs: Reqs, update: Update) -> Bool {
  let #(_, missing) =
    list.fold(update, #(set.new(), set.new()), fn(acc, i) {
      let #(seen, missing) = acc
      let req = reqs |> dict.get(i) |> result.unwrap(set.new())
      #(set.insert(seen, i), req |> set.difference(seen) |> set.union(missing))
    })
  update |> set.from_list |> set.intersection(missing) |> set.is_empty
}

fn find_middle(update: Update) -> Int {
  let n = list.length(update) / 2

  update
  |> list.drop(n)
  |> list.first
  |> result.unwrap(0)
}

fn reorder(
  update: Update,
  reqs: Reqs,
  all: Set(Int),
  seen: Set(Int),
  acc: Update,
) -> Update {
  case list.is_empty(update) {
    True -> acc
    False -> {
      let #(next, rest) =
        list.partition(update, fn(n) {
          reqs
          |> dict.get(n)
          |> result.unwrap(set.new())
          |> set.intersection(all)
          |> set.difference(seen)
          |> set.is_empty
        })

      reorder(
        rest,
        reqs,
        all,
        next |> set.from_list |> set.union(seen),
        list.append(next, acc),
      )
    }
  }
}

pub fn part1(input: String) -> Int {
  let #(rules, updates) = parser.go(input, input_p())
  let reqs = build_reqs(rules)

  updates
  |> list.filter(valid(reqs, _))
  |> list.map(find_middle)
  |> li.sum
}

pub fn part2(input: String) -> Int {
  let #(rules, updates) = parser.go(input, input_p())
  let reqs = build_reqs(rules)

  updates
  |> list.filter(fn(u) { !valid(reqs, u) })
  |> list.map(fn(u) {
    u |> reorder(reqs, set.from_list(u), set.new(), []) |> find_middle
  })
  |> li.sum
}
